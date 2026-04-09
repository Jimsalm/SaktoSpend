import 'package:SaktoSpend/data/db/app_database.dart';
import 'package:SaktoSpend/data/models/budget_model.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/budgets/domain/repositories/budget_repository.dart';
import 'package:sqflite/sqflite.dart';

class BudgetRepositoryLocal implements BudgetRepository {
  BudgetRepositoryLocal({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<void> createBudget(Budget budget) async {
    _validateBudget(budget);
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
    _validateBudgetId(budgetId);
    final db = await _database.instance;
    await db.delete(
      AppDatabase.budgetsTable,
      where: 'id = ?',
      whereArgs: [budgetId.trim()],
    );
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.budgetsTable,
      orderBy: 'updated_at DESC',
    );

    final now = DateTime.now();
    return rows.map((row) => BudgetModel.fromMap(row).toDomain()).where((
      budget,
    ) {
      final createdAt = budget.createdAt.toLocal();
      return createdAt.year == now.year && createdAt.month == now.month;
    }).toList();
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    _validateBudget(budget);
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

  void _validateBudget(Budget budget) {
    _validateBudgetId(budget.id);
    if (budget.name.trim().isEmpty) {
      throw ArgumentError.value(
        budget.name,
        'budget.name',
        'Budget name is required',
      );
    }
    if (budget.amount <= 0) {
      throw ArgumentError.value(
        budget.amount,
        'budget.amount',
        'Budget amount must be greater than zero',
      );
    }
    if (budget.warningPercent < 0 || budget.warningPercent > 100) {
      throw ArgumentError.value(
        budget.warningPercent,
        'budget.warningPercent',
        'Warning percent must be between 0 and 100',
      );
    }
  }

  void _validateBudgetId(String budgetId) {
    if (budgetId.trim().isEmpty) {
      throw ArgumentError.value(budgetId, 'budgetId', 'Budget id is required');
    }
  }
}
