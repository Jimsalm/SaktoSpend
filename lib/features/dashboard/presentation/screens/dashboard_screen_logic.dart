part of 'dashboard_screen.dart';

final _dashboardViewDataProvider = FutureProvider<_DashboardViewData>((
  ref,
) async {
  final overview = await ref.watch(dashboardOverviewProvider.future);
  return _DashboardViewData.fromDomain(overview);
});

class _DashboardViewData {
  const _DashboardViewData({
    required this.monthLabel,
    required this.totalSpentThisMonth,
    required this.avoidableSpendThisMonth,
    required this.currentMonthBudgetTotal,
    required this.spendingProgress,
    required this.spendingPercentLabel,
    required this.avoidableCategories,
    required this.recentSessions,
  });

  final String monthLabel;
  final int totalSpentThisMonth;
  final int avoidableSpendThisMonth;
  final int currentMonthBudgetTotal;
  final double spendingProgress;
  final int spendingPercentLabel;
  final List<_AvoidableCategoryViewData> avoidableCategories;
  final List<_RecentSessionViewData> recentSessions;

  factory _DashboardViewData.fromDomain(DashboardOverview overview) {
    final now = DateTime.now();
    final totalSpent = overview.totalSpentThisMonth;
    final progress = overview.currentMonthBudgetTotal <= 0
        ? 0.0
        : (totalSpent / overview.currentMonthBudgetTotal).clamp(0.0, 1.0);

    return _DashboardViewData(
      monthLabel: _monthYearLabel(now),
      totalSpentThisMonth: totalSpent,
      avoidableSpendThisMonth: overview.avoidableSpendThisMonth,
      currentMonthBudgetTotal: overview.currentMonthBudgetTotal,
      spendingProgress: progress,
      spendingPercentLabel: (progress * 100).round(),
      avoidableCategories: overview.avoidableCategories
          .map((entry) => _AvoidableCategoryViewData.fromDomain(entry))
          .toList(),
      recentSessions: overview.recentSessions
          .map((session) => _RecentSessionViewData.fromDomain(session))
          .toList(),
    );
  }
}

class _AvoidableCategoryViewData {
  const _AvoidableCategoryViewData({
    required this.label,
    required this.amountLabel,
    required this.icon,
  });

  final String label;
  final String amountLabel;
  final IconData icon;

  factory _AvoidableCategoryViewData.fromDomain(
    DashboardAvoidableCategory entry,
  ) {
    return _AvoidableCategoryViewData(
      label: entry.category,
      amountLabel: MoneyUtils.centavosToCurrency(entry.amountCentavos),
      icon: _iconForSpendCategory(entry.category),
    );
  }
}

class _RecentSessionViewData {
  const _RecentSessionViewData({
    required this.budgetId,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.typeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.amountLabel,
    required this.budgetAmountLabel,
    required this.amountColor,
  });

  final String budgetId;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String typeLabel;
  final String statusLabel;
  final Color statusColor;
  final String amountLabel;
  final String budgetAmountLabel;
  final Color amountColor;

  factory _RecentSessionViewData.fromDomain(DashboardRecentSession session) {
    final isOver =
        session.budgetAmountCentavos > 0 &&
        session.amountCentavos > session.budgetAmountCentavos;

    return _RecentSessionViewData(
      budgetId: session.budgetId,
      icon: _iconForBudget(session.name, session.type),
      iconColor: _iconColorForBudget(session.name, session.type),
      title: session.name,
      typeLabel: _labelForBudgetType(session.type),
      statusLabel: isOver ? 'Over' : (session.isActive ? 'Active' : 'Inactive'),
      statusColor: isOver ? const Color(0xFFE52420) : const Color(0xFFA4ED23),
      amountLabel: MoneyUtils.centavosToCurrency(session.amountCentavos),
      budgetAmountLabel: session.budgetAmountCentavos <= 0
          ? 'No target'
          : 'of ${MoneyUtils.centavosToCurrency(session.budgetAmountCentavos)}',
      amountColor: isOver ? const Color(0xFFE52420) : const Color(0xFF0D1530),
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

IconData _iconForBudget(String name, String type) {
  final normalizedName = name.toLowerCase();
  if (normalizedName.contains('grocer')) {
    return Icons.shopping_cart_rounded;
  }
  if (normalizedName.contains('transport') ||
      normalizedName.contains('gas') ||
      normalizedName.contains('fuel') ||
      normalizedName.contains('car')) {
    return Icons.directions_car_filled_rounded;
  }
  if (normalizedName.contains('dining') ||
      normalizedName.contains('food') ||
      normalizedName.contains('restaurant')) {
    return Icons.restaurant_rounded;
  }
  if (normalizedName.contains('utilit') ||
      normalizedName.contains('electric') ||
      normalizedName.contains('water')) {
    return Icons.home_work_rounded;
  }
  return _iconForBudgetType(type);
}

Color _iconColorForBudget(String name, String type) {
  final normalizedName = name.toLowerCase();
  if (normalizedName.contains('dining') ||
      normalizedName.contains('food') ||
      normalizedName.contains('restaurant')) {
    return const Color(0xFFE52420);
  }
  if (normalizedName.contains('transport') ||
      normalizedName.contains('gas') ||
      normalizedName.contains('fuel') ||
      normalizedName.contains('car')) {
    return const Color(0xFF1D243B);
  }
  if (normalizedName.contains('utilit') ||
      normalizedName.contains('electric') ||
      normalizedName.contains('water')) {
    return const Color(0xFF1D243B);
  }
  if (normalizedName.contains('grocer')) {
    return const Color(0xFF1D243B);
  }
  return switch (type.toLowerCase()) {
    'weekly' => const Color(0xFF1D243B),
    'monthly' => const Color(0xFF1D243B),
    _ => const Color(0xFF1D243B),
  };
}

IconData _iconForBudgetType(String type) {
  switch (type.toLowerCase()) {
    case 'weekly':
      return Icons.shopping_cart_rounded;
    case 'monthly':
      return Icons.account_balance_wallet_outlined;
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

IconData _iconForSpendCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('coffee') || normalized.contains('beverage')) {
    return Icons.local_cafe_rounded;
  }
  if (normalized.contains('lifestyle') ||
      normalized.contains('impulse') ||
      normalized.contains('shopping')) {
    return Icons.shopping_bag_rounded;
  }
  if (normalized.contains('dairy')) {
    return Icons.egg_alt_rounded;
  }
  if (normalized.contains('pantry') || normalized.contains('grain')) {
    return Icons.kitchen_rounded;
  }
  return Icons.sell_outlined;
}
