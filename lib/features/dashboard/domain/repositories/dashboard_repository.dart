import 'package:SaktoSpend/features/dashboard/domain/entities/dashboard_overview.dart';

abstract class DashboardRepository {
  Future<DashboardOverview> getOverview();
}
