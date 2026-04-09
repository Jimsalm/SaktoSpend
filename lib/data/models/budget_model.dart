import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';

class BudgetModel {
  const BudgetModel({
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
  final String type;
  final int amount;
  final double warningPercent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BudgetModel.fromDomain(Budget budget) {
    return BudgetModel(
      id: budget.id,
      name: budget.name,
      type: budget.type.name,
      amount: budget.amount,
      warningPercent: budget.warningPercent,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  factory BudgetModel.fromMap(Map<String, Object?> map) {
    final amount = MoneyUtils.dbMoneyToCentavos(map['amount']);
    return BudgetModel(
      id: map['id']! as String,
      name: map['name']! as String,
      type: map['type']! as String,
      amount: amount,
      warningPercent: (map['warning_percent']! as num).toDouble(),
      isActive: (map['is_active']! as int) == 1,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  Budget toDomain() {
    return Budget(
      id: id,
      name: name,
      type: _parseBudgetType(type),
      amount: amount,
      warningPercent: warningPercent,
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
      'warning_percent': warningPercent,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

BudgetType _parseBudgetType(String raw) {
  switch (raw) {
    case 'shopping':
    case 'category':
      return BudgetType.shopping;
    case 'weekly':
      return BudgetType.weekly;
    case 'monthly':
    case 'trip':
      return BudgetType.monthly;
    default:
      return BudgetType.shopping;
  }
}
