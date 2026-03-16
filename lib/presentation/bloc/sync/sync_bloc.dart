import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/data/api/api_service.dart';
import 'package:proactive_expense_manager/data/repositories/category_repository.dart';
import 'package:proactive_expense_manager/data/repositories/transaction_repository.dart';
import 'package:proactive_expense_manager/presentation/bloc/sync/sync_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/sync/sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ApiService apiService;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;

  SyncBloc({
    required this.apiService,
    required this.categoryRepository,
    required this.transactionRepository,
  }) : super(const SyncInitial()) {
    on<StartSync>(_onStartSync);
  }

  Future<void> _onStartSync(
    StartSync event,
    Emitter<SyncState> emit,
  ) async {
    try {
      // ─── Step A: Clean up Deletions ────────────────────────────────

      // 1. Delete transactions from cloud first
      emit(const SyncInProgress('Deleting transactions from cloud...'));
      final deletedTransactions =
          await transactionRepository.getDeletedTransactions();
      if (deletedTransactions.isNotEmpty) {
        final txIds = deletedTransactions.map((t) => t.id).toList();
        final txDeleteResponse = await apiService.deleteTransactions(txIds);
        if (txDeleteResponse['status'] == 'success') {
          final deletedIds =
              List<String>.from(txDeleteResponse['deleted_ids'] ?? []);
          await transactionRepository.permanentlyDelete(deletedIds);
        }
      }

      // 2. Delete categories from cloud
      emit(const SyncInProgress('Deleting categories from cloud...'));
      final deletedCategories =
          await categoryRepository.getDeletedCategories();
      if (deletedCategories.isNotEmpty) {
        final catIds = deletedCategories.map((c) => c.id).toList();
        final catDeleteResponse = await apiService.deleteCategories(catIds);
        if (catDeleteResponse['status'] == 'success') {
          final deletedIds =
              List<String>.from(catDeleteResponse['deleted_ids'] ?? []);
          await categoryRepository.permanentlyDelete(deletedIds);
        }
      }

      // ─── Step B: Upload New Data ───────────────────────────────────

      // 1. Sync categories first
      emit(const SyncInProgress('Syncing categories...'));
      final unsyncedCategories =
          await categoryRepository.getUnsyncedCategories();
      for (final category in unsyncedCategories) {
        final response = await apiService.addCategory(category.toApiJson());
        if (response['status'] == 'success') {
          final syncedIds =
              List<String>.from(response['synced_ids'] ?? []);
          await categoryRepository.markAsSynced(syncedIds);
        }
      }

      // 2. Sync transactions second
      emit(const SyncInProgress('Syncing transactions...'));
      final unsyncedTransactions =
          await transactionRepository.getUnsyncedTransactions();
      if (unsyncedTransactions.isNotEmpty) {
        final txJsonList =
            unsyncedTransactions.map((t) => t.toApiJson()).toList();
        final response = await apiService.addTransactions(txJsonList);
        if (response['status'] == 'success') {
          final syncedIds =
              List<String>.from(response['synced_ids'] ?? []);
          await transactionRepository.markAsSynced(syncedIds);
        }
      }

      emit(const SyncSuccess());
    } catch (e) {
      emit(SyncError(e.toString()));
    }
  }
}
