import 'package:proactive_expense_manager/data/database/database_helper.dart';
import 'package:proactive_expense_manager/data/models/category_model.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepository(this._dbHelper);

  Future<List<CategoryModel>> getActiveCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> softDeleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getUnsyncedCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'is_synced = ? AND is_deleted = ?',
      whereArgs: [0, 0],
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<List<CategoryModel>> getDeletedCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'is_deleted = ?',
      whereArgs: [1],
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<void> markAsSynced(List<String> ids) async {
    final db = await _dbHelper.database;
    for (final id in ids) {
      await db.update(
        'categories',
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
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}
