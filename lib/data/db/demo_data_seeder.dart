import 'dart:math';

import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';

class DemoDataSeeder {
  const DemoDataSeeder._();

  static Future<void> seed({
    required AppDatabase database,
    bool clearExisting = true,
  }) async {
    final db = await database.instance;
    final random = Random();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);

    final seedBudgets = <_SeedBudget>[
      ..._buildMonthBudgets(
        monthDate: currentMonth,
        isActive: true,
        random: random,
      ),
      ..._buildMonthBudgets(
        monthDate: previousMonth,
        isActive: false,
        random: random,
      ),
      ..._buildMonthBudgets(
        monthDate: twoMonthsAgo,
        isActive: false,
        random: random,
      ),
    ];

    await db.transaction((txn) async {
      if (clearExisting) {
        await txn.delete(AppDatabase.sessionCartItemsTable);
        await txn.delete(AppDatabase.budgetsTable);
      }

      for (final seedBudget in seedBudgets) {
        await txn.insert(AppDatabase.budgetsTable, seedBudget.toBudgetRow());

        final itemCount = random.nextInt(5) + 4;
        final monthDays = _daysInMonth(seedBudget.monthDate);
        for (var i = 0; i < itemCount; i++) {
          final template = _productTemplates[random.nextInt(_productTemplates.length)];
          final quantity = template.unit == 'KG'
              ? (random.nextInt(3) + 1)
              : (random.nextInt(5) + 1);
          final unitPrice = _randomCentavos(
            random: random,
            min: template.minCentavos,
            max: template.maxCentavos,
          );
          final createdAt = DateTime(
            seedBudget.monthDate.year,
            seedBudget.monthDate.month,
            random.nextInt(monthDays) + 1,
            random.nextInt(12) + 8,
            random.nextInt(60),
            random.nextInt(60),
          );

          await txn.insert(AppDatabase.sessionCartItemsTable, {
            'budget_id': seedBudget.id,
            'name': template.name,
            'category': template.category,
            'unit_price': unitPrice,
            'quantity': quantity,
            'unit': template.unit,
            'is_essential': random.nextBool() ? 1 : 0,
            'created_at': createdAt.toIso8601String(),
          });
        }
      }
    });
  }

  static List<_SeedBudget> _buildMonthBudgets({
    required DateTime monthDate,
    required bool isActive,
    required Random random,
  }) {
    final label = _monthName(monthDate.month);

    return [
      _SeedBudget(
        id: 'budget_${monthDate.year}_${monthDate.month}_shopping',
        name: '$label Shopping',
        type: BudgetType.shopping,
        amount: _randomCentavos(random: random, min: 90000, max: 220000),
        warningPercent: _warningThreshold(random),
        isActive: isActive,
        monthDate: monthDate,
      ),
      _SeedBudget(
        id: 'budget_${monthDate.year}_${monthDate.month}_weekly',
        name: '$label Weekly',
        type: BudgetType.weekly,
        amount: _randomCentavos(random: random, min: 40000, max: 120000),
        warningPercent: _warningThreshold(random),
        isActive: isActive,
        monthDate: monthDate,
      ),
      _SeedBudget(
        id: 'budget_${monthDate.year}_${monthDate.month}_monthly',
        name: '$label Monthly',
        type: BudgetType.monthly,
        amount: _randomCentavos(random: random, min: 150000, max: 500000),
        warningPercent: _warningThreshold(random),
        isActive: isActive,
        monthDate: monthDate,
      ),
    ];
  }

  static int _randomCentavos({
    required Random random,
    required int min,
    required int max,
  }) {
    final value = min + random.nextInt(max - min + 1);
    final pesos = (value / 100).floor();
    return pesos * 100;
  }

  static double _warningThreshold(Random random) {
    const values = <double>[70, 75, 80, 85, 90];
    return values[random.nextInt(values.length)];
  }

  static int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  static String _monthName(int month) {
    const names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _SeedBudget {
  const _SeedBudget({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.warningPercent,
    required this.isActive,
    required this.monthDate,
  });

  final String id;
  final String name;
  final BudgetType type;
  final int amount;
  final double warningPercent;
  final bool isActive;
  final DateTime monthDate;

  Map<String, Object?> toBudgetRow() {
    final createdAt = DateTime(monthDate.year, monthDate.month, 1, 9, 0, 0);
    final updatedAt = DateTime(monthDate.year, monthDate.month, 1, 9, 0, 0);

    return {
      'id': id,
      'name': name,
      'type': type.name,
      'amount': amount,
      'warning_percent': warningPercent,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class _ProductTemplate {
  const _ProductTemplate({
    required this.name,
    required this.category,
    required this.minCentavos,
    required this.maxCentavos,
    required this.unit,
  });

  final String name;
  final String category;
  final int minCentavos;
  final int maxCentavos;
  final String unit;
}

const _productTemplates = <_ProductTemplate>[
  _ProductTemplate(
    name: 'Organic Almond Milk',
    category: 'Beverage',
    minCentavos: 2500,
    maxCentavos: 7000,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Artisan Whole Bean Coffee',
    category: 'Pantry & Grains',
    minCentavos: 5000,
    maxCentavos: 18000,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Sparkling Mineral Water',
    category: 'Beverage',
    minCentavos: 1800,
    maxCentavos: 6000,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Greek Yogurt Pack',
    category: 'Dairy',
    minCentavos: 3000,
    maxCentavos: 9000,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Sourdough Bread',
    category: 'Pantry & Grains',
    minCentavos: 3500,
    maxCentavos: 8500,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Fresh Chicken Breast',
    category: 'Groceries',
    minCentavos: 7000,
    maxCentavos: 17000,
    unit: 'KG',
  ),
  _ProductTemplate(
    name: 'Jasmine Rice',
    category: 'Groceries',
    minCentavos: 4500,
    maxCentavos: 12000,
    unit: 'KG',
  ),
  _ProductTemplate(
    name: 'Baby Spinach',
    category: 'Groceries',
    minCentavos: 1800,
    maxCentavos: 4500,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Shampoo Refill',
    category: 'Lifestyle',
    minCentavos: 2500,
    maxCentavos: 9000,
    unit: 'PC',
  ),
  _ProductTemplate(
    name: 'Dishwashing Liquid',
    category: 'Lifestyle',
    minCentavos: 1400,
    maxCentavos: 4500,
    unit: 'PC',
  ),
];
