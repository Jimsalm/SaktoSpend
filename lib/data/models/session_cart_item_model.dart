import 'package:budget_tracker/core/utils/utils.dart';
import 'package:budget_tracker/features/shopping_session/domain/entities/session_cart_item.dart';

class SessionCartItemModel {
  const SessionCartItemModel({
    this.id,
    required this.budgetId,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.isEssential,
    required this.createdAt,
  });

  final int? id;
  final String budgetId;
  final String name;
  final String category;
  final int unitPrice;
  final int quantity;
  final String unit;
  final bool isEssential;
  final DateTime createdAt;

  factory SessionCartItemModel.fromMap(Map<String, Object?> map) {
    return SessionCartItemModel(
      id: map['id'] as int?,
      budgetId: (map['budget_id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Groceries',
      unitPrice: MoneyUtils.dbMoneyToCentavos(map['unit_price']),
      quantity: ((map['quantity'] as num?) ?? 1).toInt(),
      unit: (map['unit'] as String?) ?? 'PC',
      isEssential: ((map['is_essential'] as num?) ?? 0).toInt() == 1,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  factory SessionCartItemModel.fromDomain({
    required String budgetId,
    required SessionCartItem item,
  }) {
    return SessionCartItemModel(
      budgetId: budgetId,
      name: item.name,
      category: item.category,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      unit: item.unit,
      isEssential: item.isEssential,
      createdAt: DateTime.now(),
    );
  }

  SessionCartItem toDomain() {
    return SessionCartItem(
      name: name,
      category: category,
      unitPrice: unitPrice,
      quantity: quantity,
      unit: unit,
      isEssential: isEssential,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'budget_id': budgetId,
      'name': name,
      'category': category,
      'unit_price': unitPrice,
      'quantity': quantity,
      'unit': unit,
      'is_essential': isEssential ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
