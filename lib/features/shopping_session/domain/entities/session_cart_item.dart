enum SessionCartItemSource {
  manual('manual'),
  voice('voice'),
  labelScan('label_scan');

  const SessionCartItemSource(this.value);

  final String value;

  static SessionCartItemSource fromValue(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final source in SessionCartItemSource.values) {
      if (source.value == normalized) {
        return source;
      }
    }
    return SessionCartItemSource.manual;
  }
}

class SessionCartItem {
  const SessionCartItem({
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    this.unit = 'PC',
    this.isEssential = false,
    this.source = SessionCartItemSource.manual,
  });

  final String name;
  final String category;
  final int unitPrice;
  final int quantity;
  final String unit;
  final bool isEssential;
  final SessionCartItemSource source;

  int get totalPrice => unitPrice * quantity;

  SessionCartItem copyWith({
    String? name,
    String? category,
    int? unitPrice,
    int? quantity,
    String? unit,
    bool? isEssential,
    SessionCartItemSource? source,
  }) {
    return SessionCartItem(
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isEssential: isEssential ?? this.isEssential,
      source: source ?? this.source,
    );
  }
}
