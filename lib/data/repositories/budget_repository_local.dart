import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/data/models/budget_model.dart';
import 'package:budget_tracker/domain/entities/budget.dart';
import 'package:budget_tracker/domain/repositories/budget_repository.dart';
import 'package:sqflite/sqflite.dart';

class BudgetRepositoryLocal implements BudgetRepository {
  BudgetRepositoryLocal({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<void> createBudget(Budget budget) async {
    final db = await _database.instance;
    final model = BudgetModel.fromDomain(budget);
    await db.insert(
      AppDatabase.budgetsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final db = await _database.instance;
    await db.delete(
      AppDatabase.budgetsTable,
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.budgetsTable,
      orderBy: 'updated_at DESC',
    );
    return rows.map((row) => BudgetModel.fromMap(row).toDomain()).toList();
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final db = await _database.instance;
    final model = BudgetModel.fromDomain(budget);
    await db.update(
      AppDatabase.budgetsTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
