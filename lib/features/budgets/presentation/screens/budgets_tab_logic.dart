part of 'budgets_tab_screen.dart';

class _BudgetStatus {
  const _BudgetStatus({
    required this.label,
    required this.badgeBg,
    required this.badgeColor,
    required this.priority,
  });

  final String label;
  final Color badgeBg;
  final Color badgeColor;
  final int priority;
}

const List<BudgetType> _selectableBudgetTypes = <BudgetType>[
  BudgetType.shopping,
  BudgetType.weekly,
  BudgetType.monthly,
];

BudgetType _normalizeSelectableType(BudgetType? type) {
  if (type != null && _selectableBudgetTypes.contains(type)) {
    return type;
  }
  return BudgetType.shopping;
}

class _BudgetItemViewData {
  const _BudgetItemViewData({
    required this.budget,
    required this.spent,
    required this.left,
    required this.utilization,
    required this.status,
  });

  final Budget budget;
  final int spent;
  final int left;
  final double utilization;
  final _BudgetStatus status;
}

class _BudgetOverviewViewData {
  const _BudgetOverviewViewData({
    required this.activeItems,
    required this.inactiveItems,
    required this.remainingTotal,
    required this.averageUtilization,
    required this.overallStatus,
  });

  final List<_BudgetItemViewData> activeItems;
  final List<_BudgetItemViewData> inactiveItems;
  final int remainingTotal;
  final double averageUtilization;
  final _BudgetStatus overallStatus;
}

_BudgetOverviewViewData _buildBudgetsViewData(
  List<Budget> budgets,
  Map<String, int> sessionSpentByBudget,
) {
  _BudgetItemViewData buildItem(
    Budget budget, {
    required _BudgetStatus status,
  }) {
    final extraSpent = sessionSpentByBudget[budget.id] ?? 0;
    final spent = _spentAmount(budget, extraSpent: extraSpent);
    final left = _leftAmount(budget, extraSpent: extraSpent);
    final utilization = _utilizationProgress(budget, extraSpent: extraSpent);
    return _BudgetItemViewData(
      budget: budget,
      spent: spent,
      left: left,
      utilization: utilization,
      status: status,
    );
  }

  final activeItems = budgets.where((budget) => budget.isActive).map((budget) {
    final extraSpent = sessionSpentByBudget[budget.id] ?? 0;
    return buildItem(
      budget,
      status: _statusForBudget(budget, extraSpent: extraSpent),
    );
  }).toList();
  final inactiveItems = budgets
      .where((budget) => !budget.isActive)
      .map(
        (budget) => buildItem(
          budget,
          status: const _BudgetStatus(
            label: 'Pending',
            badgeBg: Color(0xFFEDEAE5),
            badgeColor: Color(0xFF8B857B),
            priority: 0,
          ),
        ),
      )
      .toList();

  final remainingTotal = activeItems.fold<int>(
    0,
    (sum, item) => sum + item.left,
  );
  final averageUtilization = activeItems.isEmpty
      ? 0.0
      : activeItems.fold<double>(0.0, (sum, item) => sum + item.utilization) /
            activeItems.length;
  final overallStatus = _overallStatus(activeItems);

  return _BudgetOverviewViewData(
    activeItems: activeItems,
    inactiveItems: inactiveItems,
    remainingTotal: remainingTotal,
    averageUtilization: averageUtilization,
    overallStatus: overallStatus,
  );
}

_BudgetStatus _statusForBudget(Budget budget, {int extraSpent = 0}) {
  final utilization = _utilizationProgress(budget, extraSpent: extraSpent);
  final warningThreshold = (budget.warningPercent / 100)
      .clamp(0.0, 1.0)
      .toDouble();

  if (utilization >= 1) {
    return const _BudgetStatus(
      label: 'Exceeded',
      badgeBg: Color(0xFF111111),
      badgeColor: Colors.white,
      priority: 2,
    );
  }

  if (utilization >= warningThreshold) {
    return const _BudgetStatus(
      label: 'Warning',
      badgeBg: Color(0xFFFBE3E0),
      badgeColor: Color(0xFFB81A16),
      priority: 1,
    );
  }

  return const _BudgetStatus(
    label: 'Safe',
    badgeBg: Color(0xFFE9E7E2),
    badgeColor: Color(0xFF1B1B1B),
    priority: 0,
  );
}

_BudgetStatus _overallStatus(List<_BudgetItemViewData> items) {
  if (items.isEmpty) {
    return const _BudgetStatus(
      label: 'N/A',
      badgeBg: Color(0xFFE9E7E2),
      badgeColor: Color(0xFF1B1B1B),
      priority: 0,
    );
  }

  return items
      .map((item) => item.status)
      .reduce((a, b) => a.priority >= b.priority ? a : b);
}

int _spentAmount(Budget budget, {int extraSpent = 0}) {
  return math.max(0, extraSpent);
}

int _leftAmount(Budget budget, {int extraSpent = 0}) {
  return budget.amount - _spentAmount(budget, extraSpent: extraSpent);
}

double _utilizationProgress(Budget budget, {int extraSpent = 0}) {
  if (budget.amount <= 0) {
    return 0;
  }
  return _spentAmount(budget, extraSpent: extraSpent) / budget.amount;
}

IconData _iconForType(BudgetType type) {
  switch (type) {
    case BudgetType.shopping:
      return Icons.shopping_basket_outlined;
    case BudgetType.weekly:
      return Icons.calendar_view_week_outlined;
    case BudgetType.monthly:
      return Icons.calendar_month_outlined;
  }
}

String _labelForType(BudgetType type) {
  switch (type) {
    case BudgetType.shopping:
      return 'Shopping';
    case BudgetType.weekly:
      return 'Weekly';
    case BudgetType.monthly:
      return 'Monthly';
  }
}

String _money(int value) => MoneyUtils.centavosToCurrency(value);

String _monthYearLabel(DateTime date) {
  const months = [
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
  return '${months[date.month - 1]} ${date.year}';
}
