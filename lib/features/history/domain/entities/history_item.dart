class HistoryItem {
  const HistoryItem({
    required this.budgetId,
    required this.name,
    required this.type,
    required this.warningPercent,
    required this.isActive,
    required this.amountCentavos,
    required this.createdAt,
  });

  final String budgetId;
  final String name;
  final String type;
  final double warningPercent;
  final bool isActive;
  final int amountCentavos;
  final DateTime createdAt;
}
