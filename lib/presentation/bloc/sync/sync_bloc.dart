import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/data/api/api_service.dart';
import 'package:proactive_expense_manager/data/models/category_model.dart';
import 'package:proactive_expense_manager/data/models/transaction_model.dart';
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

  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    try {
      // ─── Step A: Clean up Deletions ────────────────────────────────

      // 1. Delete transactions from cloud first
      emit(const SyncInProgress('Deleting transactions from cloud...'));
      debugPrint('SyncBloc: Step A.1 — Deleting transactions from cloud');
      final deletedTransactions = await transactionRepository
          .getDeletedTransactions();
      if (deletedTransactions.isNotEmpty) {
        final txIds = deletedTransactions.map((t) => t.id).toList();
        debugPrint(
          'SyncBloc: Sending ${txIds.length} transaction IDs for cloud deletion',
        );
        final txDeleteResponse = await apiService.deleteTransactions(txIds);
        if (txDeleteResponse['status'] == 'success') {
          final deletedIds = List<String>.from(
            txDeleteResponse['deleted_ids'] ?? [],
          );
          await transactionRepository.permanentlyDelete(deletedIds);
          debugPrint(
            'SyncBloc: Permanently deleted ${deletedIds.length} transactions locally',
          );
        }
      } else {
        debugPrint('SyncBloc: No deleted transactions to purge');
      }

      // 2. Delete categories from cloud
      emit(const SyncInProgress('Deleting categories from cloud...'));
      debugPrint('SyncBloc: Step A.2 — Deleting categories from cloud');
      final deletedCategories = await categoryRepository.getDeletedCategories();
      if (deletedCategories.isNotEmpty) {
        final catIds = deletedCategories.map((c) => c.id).toList();
        debugPrint(
          'SyncBloc: Sending ${catIds.length} category IDs for cloud deletion',
        );
        final catDeleteResponse = await apiService.deleteCategories(catIds);
        if (catDeleteResponse['status'] == 'success') {
          final deletedIds = List<String>.from(
            catDeleteResponse['deleted_ids'] ?? [],
          );
          await categoryRepository.permanentlyDelete(deletedIds);
          debugPrint(
            'SyncBloc: Permanently deleted ${deletedIds.length} categories locally',
          );
        }
      } else {
        debugPrint('SyncBloc: No deleted categories to purge');
      }

      // ─── Step B: Upload New Data ───────────────────────────────────

      // 1. Sync categories first
      emit(const SyncInProgress('Syncing categories...'));
      debugPrint('SyncBloc: Step B.1 — Uploading unsynced categories');
      final unsyncedCategories = await categoryRepository
          .getUnsyncedCategories();
      debugPrint(
        'SyncBloc: Found ${unsyncedCategories.length} unsynced categories',
      );
      for (final category in unsyncedCategories) {
        final response = await apiService.addCategory(category.toApiJson());
        if (response['status'] == 'success') {
          final syncedIds = List<String>.from(response['synced_ids'] ?? []);
          await categoryRepository.markAsSynced(syncedIds);
          debugPrint('SyncBloc: Marked category as synced → ${category.name}');
        } else if (response['message'] == 'Category already exists') {
          // Category already on server — mark local record as synced
          await categoryRepository.markAsSynced([category.id]);
          debugPrint(
            'SyncBloc: Category already exists on server, marked as synced → ${category.name}',
          );
        }
      }

      // 2. Sync transactions second
      emit(const SyncInProgress('Syncing transactions...'));
      debugPrint('SyncBloc: Step B.2 — Uploading unsynced transactions');
      final unsyncedTransactions = await transactionRepository
          .getUnsyncedTransactions();
      debugPrint(
        'SyncBloc: Found ${unsyncedTransactions.length} unsynced transactions',
      );
      if (unsyncedTransactions.isNotEmpty) {
        final txJsonList = unsyncedTransactions
            .map((t) => t.toApiJson())
            .toList();
        final response = await apiService.addTransactions(txJsonList);
        if (response['status'] == 'success') {
          // Try synced_ids first; fall back to local IDs if server doesn't return them
          var syncedIds = List<String>.from(response['synced_ids'] ?? []);
          if (syncedIds.isEmpty) {
            syncedIds = unsyncedTransactions.map((t) => t.id).toList();
            debugPrint(
              'SyncBloc: Server did not return synced_ids, using local IDs',
            );
          }
          await transactionRepository.markAsSynced(syncedIds);
          debugPrint(
            'SyncBloc: Marked ${syncedIds.length} transactions as synced',
          );
        }
      }

      // ─── Step C: Fetch Cloud Data ──────────────────────────────────

      // 1. Fetch categories from cloud
      emit(const SyncInProgress('Fetching categories from cloud...'));
      debugPrint('SyncBloc: Step C.1 — GET /categories/');
      final catResponse = await apiService.getCategories();
      if (catResponse['status'] == 'success') {
        final cloudCatList = catResponse['categories'] as List<dynamic>? ?? [];
        debugPrint('SyncBloc: API returned ${cloudCatList.length} categories');
        final cloudCategories = cloudCatList.map((json) {
          final map = json as Map<String, dynamic>;
          // API returns "category_id", not "id"
          final id = (map['category_id'] ?? map['id']) as String;
          return CategoryModel(
            id: id,
            name: map['name'] as String,
            isSynced: 1,
            isDeleted: 0,
          );
        }).toList();
        final insertedCats = await categoryRepository.mergeFromCloud(
          cloudCategories,
        );
        debugPrint('SyncBloc: Merged $insertedCats new categories from cloud');
      }

      // 2. Fetch transactions from cloud
      emit(const SyncInProgress('Fetching transactions from cloud...'));
      debugPrint('SyncBloc: Step C.2 — GET /transactions/');
      final txResponse = await apiService.getTransactions();
      if (txResponse['status'] == 'success') {
        final cloudTxList = txResponse['transactions'] as List<dynamic>? ?? [];
        debugPrint('SyncBloc: API returned ${cloudTxList.length} transactions');
        final cloudTransactions = cloudTxList.map((json) {
          final map = json as Map<String, dynamic>;
          return TransactionModel(
            id: map['id'] as String,
            amount: (map['amount'] as num).toDouble(),
            note: map['note'] as String? ?? '',
            type: map['type'] as String,
            categoryId: map['category_id'] as String? ?? '',
            timestamp: map['timestamp'] as String? ?? '',
            isSynced: 1,
            isDeleted: 0,
          );
        }).toList();
        final insertedTxs = await transactionRepository.mergeFromCloud(
          cloudTransactions,
        );
        debugPrint('SyncBloc: Merged $insertedTxs new transactions from cloud');
      }

      debugPrint('SyncBloc: ✓ Sync completed successfully');
      emit(const SyncSuccess());
    } catch (e) {
      debugPrint('SyncBloc: ✗ Sync failed — $e');
      emit(SyncError(e.toString()));
    }
  }
}
