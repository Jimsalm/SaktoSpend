class DashboardRecentSession {
  const DashboardRecentSession({
    required this.budgetId,
    required this.name,
    required this.type,
    required this.amountCentavos,
    required this.occurredAt,
    required this.isActive,
  });

  final String budgetId;
  final String name;
  final String type;
  final int amountCentavos;
  final DateTime occurredAt;
  final bool isActive;
}
