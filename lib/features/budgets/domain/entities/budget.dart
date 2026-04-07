enum BudgetType {
  shopping,
  weekly,
  monthly,
}

class Budget {
  const Budget({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.warningPercent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final BudgetType type;
  final int amount;
  final double warningPercent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
