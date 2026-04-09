import 'package:SaktoSpend/features/history/domain/entities/history_item.dart';

class HistoryMonthSection {
  const HistoryMonthSection({
    required this.year,
    required this.month,
    required this.totalCentavos,
    required this.items,
  });

  final int year;
  final int month;
  final int totalCentavos;
  final List<HistoryItem> items;
}
