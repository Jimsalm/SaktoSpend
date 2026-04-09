import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:budget_tracker/features/dashboard/domain/entities/dashboard_recent_session.dart';
import 'package:budget_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryLocal implements DashboardRepository {
  DashboardRepositoryLocal({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<DashboardOverview> getOverview() async {
    final db = await _database.instance;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final startIso = startOfMonth.toIso8601String();
    final endIso = startOfNextMonth.toIso8601String();

    final totalSpentRow = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(s.unit_price * s.quantity), 0) AS total
      FROM ${AppDatabase.sessionCartItemsTable} s
      INNER JOIN ${AppDatabase.budgetsTable} b ON b.id = s.budget_id
      WHERE s.created_at >= ? AND s.created_at < ?
        AND b.is_active = 1
        AND b.created_at >= ? AND b.created_at < ?
      ''',
      [startIso, endIso, startIso, endIso],
    );

    final avoidableSpentRow = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(s.unit_price * s.quantity), 0) AS total
      FROM ${AppDatabase.sessionCartItemsTable} s
      INNER JOIN ${AppDatabase.budgetsTable} b ON b.id = s.budget_id
      WHERE s.created_at >= ? AND s.created_at < ?
        AND s.is_essential = 0
        AND b.is_active = 1
        AND b.created_at >= ? AND b.created_at < ?
      ''',
      [startIso, endIso, startIso, endIso],
    );

    final essentialSpentRow = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(s.unit_price * s.quantity), 0) AS total
      FROM ${AppDatabase.sessionCartItemsTable} s
      INNER JOIN ${AppDatabase.budgetsTable} b ON b.id = s.budget_id
      WHERE s.created_at >= ? AND s.created_at < ?
        AND s.is_essential = 1
        AND b.is_active = 1
        AND b.created_at >= ? AND b.created_at < ?
      ''',
      [startIso, endIso, startIso, endIso],
    );

    final budgetTotalRow = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM ${AppDatabase.budgetsTable}
      WHERE created_at >= ? AND created_at < ? AND is_active = 1
      ''',
      [startIso, endIso],
    );

    final recentRows = await db.rawQuery(
      '''
      SELECT
        b.id AS budget_id,
        b.name,
        b.type,
        b.is_active,
        b.updated_at,
        COALESCE(SUM(s.unit_price * s.quantity), 0) AS spent_total
      FROM ${AppDatabase.budgetsTable} b
      LEFT JOIN ${AppDatabase.sessionCartItemsTable} s
        ON s.budget_id = b.id
      WHERE b.created_at >= ? AND b.created_at < ? AND b.is_active = 1
      GROUP BY b.id, b.name, b.type, b.is_active, b.updated_at
      ORDER BY datetime(b.updated_at) DESC, b.id DESC
      LIMIT 6
      ''',
      [startIso, endIso],
    );

    final recentSessions = recentRows.map((row) {
      final parsedDate =
          DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
          DateTime.now();
      return DashboardRecentSession(
        budgetId: ((row['budget_id'] as String?) ?? '').trim(),
        name: ((row['name'] as String?) ?? '').trim().isEmpty
            ? 'Unnamed budget'
            : (row['name'] as String).trim(),
        type: ((row['type'] as String?) ?? '').trim().isEmpty
            ? 'shopping'
            : (row['type'] as String).trim(),
        amountCentavos: _asInt(row['spent_total']),
        occurredAt: parsedDate.toLocal(),
        isActive: _asInt(row['is_active']) == 1,
      );
    }).toList();

    return DashboardOverview(
      totalSpentThisMonth: _firstTotal(totalSpentRow),
      avoidableSpendThisMonth: _firstTotal(avoidableSpentRow),
      essentialSpendThisMonth: _firstTotal(essentialSpentRow),
      currentMonthBudgetTotal: _firstTotal(budgetTotalRow),
      recentSessions: recentSessions,
    );
  }
}

int _firstTotal(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) {
    return 0;
  }
  return _asInt(rows.first['total']);
}

int _asInt(Object? value) {
  switch (value) {
    case int number:
      return number;
    case num number:
      return number.round();
    case String text:
      return int.tryParse(text) ?? 0;
    default:
      return 0;
  }
}
