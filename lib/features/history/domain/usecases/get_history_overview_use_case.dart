import 'package:SaktoSpend/features/history/domain/entities/history_overview.dart';
import 'package:SaktoSpend/features/history/domain/repositories/history_repository.dart';

class GetHistoryOverviewUseCase {
  const GetHistoryOverviewUseCase(this._repository);

  final HistoryRepository _repository;

  Future<HistoryOverview> call() {
    return _repository.getOverview();
  }
}
