import 'package:SaktoSpend/data/db/app_database.dart';
import 'package:SaktoSpend/features/history/domain/entities/history_item.dart';
import 'package:SaktoSpend/features/history/domain/entities/history_month_section.dart';
import 'package:SaktoSpend/features/history/domain/entities/history_overview.dart';
import 'package:SaktoSpend/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryLocal implements HistoryRepository {
  HistoryRepositoryLocal({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<HistoryOverview> getOverview() async {
    final db = await _database.instance;
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

    final budgetRows = await db.query(
      AppDatabase.budgetsTable,
      columns: const [
        'id',
        'name',
        'type',
        'amount',
        'warning_percent',
        'is_active',
        'created_at',
        'updated_at',
      ],
      orderBy: 'datetime(created_at) DESC, id DESC',
    );

    final previousMonthBudgets = budgetRows
        .map(_HistoryBudgetRow.fromMap)
        .where((entry) => entry.monthStart.isBefore(currentMonthStart))
        .toList();

    final groupedByMonth = <_MonthKey, List<_HistoryBudgetRow>>{};
    for (final entry in previousMonthBudgets) {
      final key = _MonthKey(entry.createdAt.year, entry.createdAt.month);
      (groupedByMonth[key] ??= <_HistoryBudgetRow>[]).add(entry);
    }

    final sortedMonthKeys = groupedByMonth.keys.toList()
      ..sort((a, b) {
        if (a.year != b.year) {
          return b.year.compareTo(a.year);
        }
        return b.month.compareTo(a.month);
      });

    final sections = sortedMonthKeys.map((monthKey) {
      final monthEntries = groupedByMonth[monthKey]!
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final monthTotal = monthEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.amount,
      );

      return HistoryMonthSection(
        year: monthKey.year,
        month: monthKey.month,
        totalCentavos: monthTotal,
        items: monthEntries
            .map(
              (entry) => HistoryItem(
                budgetId: entry.id,
                name: entry.name,
                type: entry.type,
                warningPercent: entry.warningPercent,
                isActive: entry.isActive,
                amountCentavos: entry.amount,
                createdAt: entry.createdAt,
              ),
            )
            .toList(),
      );
    }).toList();

    return HistoryOverview(sections: sections);
  }
}

class _HistoryBudgetRow {
  const _HistoryBudgetRow({
    required this.id,
    required this.name,
    required this.type,
    required this.warningPercent,
    required this.amount,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String type;
  final double warningPercent;
  final int amount;
  final bool isActive;
  final DateTime createdAt;

  DateTime get monthStart => DateTime(createdAt.year, createdAt.month, 1);

  factory _HistoryBudgetRow.fromMap(Map<String, Object?> map) {
    final createdAtRaw = (map['created_at'] as String?) ?? '';
    final updatedAtRaw = (map['updated_at'] as String?) ?? '';
    final createdAt =
        DateTime.tryParse(createdAtRaw) ??
        DateTime.tryParse(updatedAtRaw) ??
        DateTime.now();

    final rawName = ((map['name'] as String?) ?? '').trim();
    final rawType = ((map['type'] as String?) ?? '').trim().toLowerCase();
    final rawId = ((map['id'] as String?) ?? '').trim();

    return _HistoryBudgetRow(
      id: rawId.isEmpty ? 'unknown_budget' : rawId,
      name: rawName.isEmpty ? 'Unnamed budget' : rawName,
      type: rawType.isEmpty ? 'shopping' : rawType,
      warningPercent: (map['warning_percent'] as num?)?.toDouble() ?? 80,
      amount: _asInt(map['amount']),
      isActive: _asInt(map['is_active']) == 1,
      createdAt: createdAt.toLocal(),
    );
  }
}

class _MonthKey {
  const _MonthKey(this.year, this.month);

  final int year;
  final int month;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _MonthKey && other.year == year && other.month == month;
  }

  @override
  int get hashCode => Object.hash(year, month);
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
