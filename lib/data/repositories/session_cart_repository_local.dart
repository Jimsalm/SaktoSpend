import 'package:SaktoSpend/data/db/app_database.dart';
import 'package:SaktoSpend/data/models/session_cart_item_model.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:SaktoSpend/features/shopping_session/domain/repositories/session_cart_repository.dart';
import 'package:sqflite/sqflite.dart';

class SessionCartRepositoryLocal implements SessionCartRepository {
  SessionCartRepositoryLocal({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<List<SessionCartItem>> getItemsForBudget(String budgetId) async {
    _validateBudgetId(budgetId);
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.sessionCartItemsTable,
      where: 'budget_id = ?',
      whereArgs: [budgetId.trim()],
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => SessionCartItemModel.fromMap(row).toDomain())
        .toList();
  }

  @override
  Future<Map<String, int>> getTotalsByBudget() async {
    final db = await _database.instance;
    final rows = await db.rawQuery('''
      SELECT budget_id, SUM(unit_price * quantity) AS total_spent
      FROM ${AppDatabase.sessionCartItemsTable}
      GROUP BY budget_id
    ''');

    return {
      for (final row in rows)
        (row['budget_id'] as String): switch (row['total_spent']) {
          int value => value,
          num value => value.round(),
          _ => 0,
        },
    };
  }

  @override
  Future<void> addItem({
    required String budgetId,
    required SessionCartItem item,
  }) async {
    _validateBudgetId(budgetId);
    final sanitizedItem = _sanitizeItem(item);
    _validateItem(sanitizedItem);
    final db = await _database.instance;
    final model = SessionCartItemModel.fromDomain(
      budgetId: budgetId.trim(),
      item: sanitizedItem,
    );
    await db.insert(
      AppDatabase.sessionCartItemsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> clearForBudget(String budgetId) async {
    _validateBudgetId(budgetId);
    final db = await _database.instance;
    await db.delete(
      AppDatabase.sessionCartItemsTable,
      where: 'budget_id = ?',
      whereArgs: [budgetId.trim()],
    );
  }

  @override
  Future<void> replaceItemsForBudget({
    required String budgetId,
    required List<SessionCartItem> items,
  }) async {
    _validateBudgetId(budgetId);
    final normalizedBudgetId = budgetId.trim();
    final sanitizedItems = items.map(_sanitizeItem).toList();
    for (final item in sanitizedItems) {
      _validateItem(item);
    }

    final db = await _database.instance;
    await db.transaction((txn) async {
      await txn.delete(
        AppDatabase.sessionCartItemsTable,
        where: 'budget_id = ?',
        whereArgs: [normalizedBudgetId],
      );

      for (final item in sanitizedItems) {
        final model = SessionCartItemModel.fromDomain(
          budgetId: normalizedBudgetId,
          item: item,
        );
        await txn.insert(
          AppDatabase.sessionCartItemsTable,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }

  SessionCartItem _sanitizeItem(SessionCartItem item) {
    return item.copyWith(
      name: item.name.trim(),
      category: item.category.trim(),
      unit: item.unit.trim().toUpperCase(),
    );
  }

  void _validateBudgetId(String budgetId) {
    if (budgetId.trim().isEmpty) {
      throw ArgumentError.value(budgetId, 'budgetId', 'Budget id is required');
    }
  }

  void _validateItem(SessionCartItem item) {
    if (item.name.isEmpty) {
      throw ArgumentError.value(
        item.name,
        'item.name',
        'Item name is required',
      );
    }
    if (item.category.isEmpty) {
      throw ArgumentError.value(
        item.category,
        'item.category',
        'Item category is required',
      );
    }
    if (item.unitPrice < 0) {
      throw ArgumentError.value(
        item.unitPrice,
        'item.unitPrice',
        'Unit price must be greater than or equal to zero',
      );
    }
    if (item.quantity <= 0) {
      throw ArgumentError.value(
        item.quantity,
        'item.quantity',
        'Quantity must be greater than zero',
      );
    }
    if (item.unit != 'PC' && item.unit != 'KG') {
      throw ArgumentError.value(
        item.unit,
        'item.unit',
        'Unit must be either PC or KG',
      );
    }
  }
}
