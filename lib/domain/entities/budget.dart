enum BudgetType {
  trip,
  weekly,
  monthly,
  category,
}

class Budget {
  const Budget({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.reserveAmount,
    required this.warningPercent,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final BudgetType type;
  final double amount;
  final double reserveAmount;
  final double warningPercent;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get spendableAmount => amount - reserveAmount;
}
