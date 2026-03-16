import 'package:equatable/equatable.dart';
import 'package:proactive_expense_manager/data/models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> recentTransactions;
  final double totalIncome;
  final double totalExpense;

  const TransactionLoaded({
    required this.allTransactions,
    required this.recentTransactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props =>
      [allTransactions, recentTransactions, totalIncome, totalExpense];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
