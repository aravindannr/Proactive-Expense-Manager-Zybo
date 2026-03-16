import 'package:proactive_expense_manager/data/database/database_helper.dart';
import 'package:proactive_expense_manager/data/models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepository(this._dbHelper);

  /// Fetch all active transactions with category name via SQL JOIN
  Future<List<TransactionModel>> getActiveTransactions() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name AS category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
    ''');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Fetch the 10 most recent active transactions with category name
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name AS category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
      LIMIT ?
    ''', [limit]);
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<void> softDeleteTransaction(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'transactions',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'is_synced = ? AND is_deleted = ?',
      whereArgs: [0, 0],
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getDeletedTransactions() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'is_deleted = ?',
      whereArgs: [1],
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> markAsSynced(List<String> ids) async {
    final db = await _dbHelper.database;
    for (final id in ids) {
      await db.update(
        'transactions',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> permanentlyDelete(List<String> ids) async {
    final db = await _dbHelper.database;
    for (final id in ids) {
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Get total debit (expenses) for the current month
  Future<double> getCurrentMonthTotalDebit() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
    final monthEnd = DateTime(now.year, now.month + 1, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'debit' AND is_deleted = 0
        AND timestamp >= ? AND timestamp < ?
    ''', [monthStart, monthEnd]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total income (credit) for active transactions
  Future<double> getTotalIncome() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'credit' AND is_deleted = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total expense (debit) for active transactions
  Future<double> getTotalExpense() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'debit' AND is_deleted = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
