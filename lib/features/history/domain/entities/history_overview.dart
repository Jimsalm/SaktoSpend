import 'package:budget_tracker/features/history/domain/entities/history_month_section.dart';

class HistoryOverview {
  const HistoryOverview({required this.sections});

  final List<HistoryMonthSection> sections;
}
