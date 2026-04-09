import 'package:budget_tracker/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:budget_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardOverviewUseCase {
  const GetDashboardOverviewUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardOverview> call() {
    return _repository.getOverview();
  }
}
