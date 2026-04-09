part of 'dashboard_screen.dart';

final _dashboardViewDataProvider = FutureProvider<_DashboardViewData>((ref) async {
  final overview = await ref.watch(dashboardOverviewProvider.future);
  return _DashboardViewData.fromDomain(overview);
});

class _DashboardViewData {
  const _DashboardViewData({
    required this.monthLabel,
    required this.totalSpentThisMonth,
    required this.avoidableSpendThisMonth,
    required this.essentialSpendThisMonth,
    required this.spendingProgress,
    required this.insightSummary,
    required this.recentSessions,
  });

  final String monthLabel;
  final int totalSpentThisMonth;
  final int avoidableSpendThisMonth;
  final int essentialSpendThisMonth;
  final double spendingProgress;
  final String insightSummary;
  final List<_RecentSessionViewData> recentSessions;

  factory _DashboardViewData.fromDomain(DashboardOverview overview) {
    final now = DateTime.now();
    final totalSpent = overview.totalSpentThisMonth;
    final avoidable = overview.avoidableSpendThisMonth;
    final essential = overview.essentialSpendThisMonth;
    final avoidableSharePercent = totalSpent <= 0
        ? 0
        : ((avoidable / totalSpent) * 100).round();

    final progress = overview.currentMonthBudgetTotal <= 0
        ? 0.0
        : (totalSpent / overview.currentMonthBudgetTotal).clamp(0.0, 1.0);

    final summary = overview.currentMonthBudgetTotal <= 0
        ? 'No active monthly budget target set yet.'
        : '$avoidableSharePercent% of this month spend is non-essential.';

    return _DashboardViewData(
      monthLabel: _monthYearLabel(now).toUpperCase(),
      totalSpentThisMonth: totalSpent,
      avoidableSpendThisMonth: avoidable,
      essentialSpendThisMonth: essential,
      spendingProgress: progress,
      insightSummary: summary,
      recentSessions: overview.recentSessions
          .map((session) => _RecentSessionViewData.fromDomain(session))
          .toList(),
    );
  }
}

class _RecentSessionViewData {
  const _RecentSessionViewData({
    required this.budgetId,
    required this.icon,
    required this.title,
    required this.meta,
    required this.amountLabel,
  });

  final String budgetId;
  final IconData icon;
  final String title;
  final String meta;
  final String amountLabel;

  factory _RecentSessionViewData.fromDomain(DashboardRecentSession session) {
    return _RecentSessionViewData(
      budgetId: session.budgetId,
      icon: _iconForBudgetType(session.type),
      title: session.name,
      meta:
          '${_labelForBudgetType(session.type).toUpperCase()} • ${session.isActive ? 'ACTIVE' : 'INACTIVE'}',
      amountLabel: MoneyUtils.centavosToCurrency(session.amountCentavos),
    );
  }
}

String _monthYearLabel(DateTime date) {
  return '${_monthName(date.month)} ${date.year}';
}

String _monthName(int month) {
  const monthNames = <String>[
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

  if (month < 1 || month > 12) {
    return 'Unknown';
  }
  return monthNames[month - 1];
}

IconData _iconForBudgetType(String type) {
  switch (type.toLowerCase()) {
    case 'weekly':
      return Icons.calendar_view_week_outlined;
    case 'monthly':
      return Icons.calendar_month_outlined;
    case 'shopping':
    default:
      return Icons.shopping_basket_outlined;
  }
}

String _labelForBudgetType(String type) {
  switch (type.toLowerCase()) {
    case 'weekly':
      return 'Weekly';
    case 'monthly':
      return 'Monthly';
    case 'shopping':
    default:
      return 'Shopping';
  }
}
