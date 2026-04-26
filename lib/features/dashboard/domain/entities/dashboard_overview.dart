import 'package:SaktoSpend/features/dashboard/domain/entities/dashboard_avoidable_category.dart';
import 'package:SaktoSpend/features/dashboard/domain/entities/dashboard_recent_session.dart';

class DashboardOverview {
  const DashboardOverview({
    required this.totalSpentThisMonth,
    required this.avoidableSpendThisMonth,
    required this.essentialSpendThisMonth,
    required this.currentMonthBudgetTotal,
    required this.avoidableCategories,
    required this.recentSessions,
  });

  final int totalSpentThisMonth;
  final int avoidableSpendThisMonth;
  final int essentialSpendThisMonth;
  final int currentMonthBudgetTotal;
  final List<DashboardAvoidableCategory> avoidableCategories;
  final List<DashboardRecentSession> recentSessions;
}
