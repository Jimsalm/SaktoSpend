import 'package:budget_tracker/features/dashboard/domain/entities/dashboard_overview.dart';

abstract class DashboardRepository {
  Future<DashboardOverview> getOverview();
}
