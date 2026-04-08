import 'package:budget_tracker/features/history/domain/entities/history_overview.dart';

abstract class HistoryRepository {
  Future<HistoryOverview> getOverview();
}
