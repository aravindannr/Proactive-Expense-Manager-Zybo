import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:proactive_expense_manager/data/models/transaction_model.dart';
import 'package:proactive_expense_manager/data/repositories/transaction_repository.dart';
import 'package:proactive_expense_manager/services/notification_service.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;
  final NotificationService notificationService;
  static const _uuid = Uuid();

  TransactionBloc({
    required this.repository,
    required this.notificationService,
  }) : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      await _emitLoaded(emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        amount: event.amount,
        note: event.note,
        type: event.type,
        categoryId: event.categoryId,
        timestamp: DateTime.now().toIso8601String(),
        isSynced: 0,
        isDeleted: 0,
      );
      await repository.insertTransaction(transaction);

      // Check budget limit for debit transactions
      if (event.type == 'debit') {
        await _checkBudgetLimit();
      }

      // Immediately update BLoC state
      await _emitLoaded(emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.softDeleteTransaction(event.id);

      // Immediately filter from BLoC state
      await _emitLoaded(emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _emitLoaded(Emitter<TransactionState> emit) async {
    final allTransactions = await repository.getActiveTransactions();
    final recentTransactions = await repository.getRecentTransactions(limit: 10);
    final totalIncome = await repository.getTotalIncome();
    final totalExpense = await repository.getTotalExpense();

    emit(TransactionLoaded(
      allTransactions: allTransactions,
      recentTransactions: recentTransactions,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    ));
  }

  Future<void> _checkBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final limit = prefs.getInt('alert_limit') ?? 1000;
    final monthlyDebit = await repository.getCurrentMonthTotalDebit();
    if (monthlyDebit > limit) {
      await notificationService.showBudgetExceededNotification(
        monthlyDebit,
        limit.toDouble(),
      );
    }
  }
}
