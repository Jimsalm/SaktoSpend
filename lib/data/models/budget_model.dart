import 'package:budget_tracker/domain/entities/budget.dart';

class BudgetModel {
  const BudgetModel({
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
  final String type;
  final double amount;
  final double reserveAmount;
  final double warningPercent;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BudgetModel.fromDomain(Budget budget) {
    return BudgetModel(
      id: budget.id,
      name: budget.name,
      type: budget.type.name,
      amount: budget.amount,
      reserveAmount: budget.reserveAmount,
      warningPercent: budget.warningPercent,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  factory BudgetModel.fromMap(Map<String, Object?> map) {
    return BudgetModel(
      id: map['id']! as String,
      name: map['name']! as String,
      type: map['type']! as String,
      amount: (map['amount']! as num).toDouble(),
      reserveAmount: (map['reserve_amount']! as num).toDouble(),
      warningPercent: (map['warning_percent']! as num).toDouble(),
      startDate: DateTime.parse(map['start_date']! as String),
      endDate: DateTime.parse(map['end_date']! as String),
      isActive: (map['is_active']! as int) == 1,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  Budget toDomain() {
    return Budget(
      id: id,
      name: name,
      type: BudgetType.values.byName(type),
      amount: amount,
      reserveAmount: reserveAmount,
      warningPercent: warningPercent,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'reserve_amount': reserveAmount,
      'warning_percent': warningPercent,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
