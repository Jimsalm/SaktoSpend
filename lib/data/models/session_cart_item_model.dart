import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';

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
    required this.source,
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
  final SessionCartItemSource source;
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
      source: SessionCartItemSource.fromValue(
        (map['source_type'] as String?) ?? 'manual',
      ),
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
      source: item.source,
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
      source: source,
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
      'source_type': source.value,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
