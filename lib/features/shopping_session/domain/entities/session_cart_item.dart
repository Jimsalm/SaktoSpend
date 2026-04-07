class SessionCartItem {
  const SessionCartItem({
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    this.unit = 'PC',
    this.isEssential = false,
  });

  final String name;
  final String category;
  final int unitPrice;
  final int quantity;
  final String unit;
  final bool isEssential;

  int get totalPrice => unitPrice * quantity;

  SessionCartItem copyWith({
    String? name,
    String? category,
    int? unitPrice,
    int? quantity,
    String? unit,
    bool? isEssential,
  }) {
    return SessionCartItem(
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isEssential: isEssential ?? this.isEssential,
    );
  }
}
