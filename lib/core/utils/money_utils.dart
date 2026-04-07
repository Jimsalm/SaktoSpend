class MoneyUtils {
  const MoneyUtils._();

  static int parseCurrencyToCentavos(String raw) {
    final sanitized = raw
        .replaceAll(',', '')
        .replaceAll('₱', '')
        .replaceAll(String.fromCharCode(36), '')
        .trim();
    if (sanitized.isEmpty) {
      return 0;
    }

    final sign = sanitized.startsWith('-') ? -1 : 1;
    final unsigned = sanitized.replaceFirst('-', '');
    final parts = unsigned.split('.');
    final whole = int.tryParse(parts.first) ?? 0;
    final decimalPart = parts.length > 1 ? parts[1] : '';
    final fractional =
        int.tryParse(decimalPart.padRight(2, '0').substring(0, 2)) ?? 0;
    return sign * ((whole * 100) + fractional);
  }

  static int numToCentavos(num value) {
    return (value * 100).round();
  }

  static int dbMoneyToCentavos(Object? raw) {
    return switch (raw) {
      int value => value,
      num value => _dbNumToCentavos(value.toDouble()),
      _ => 0,
    };
  }

  static String centavosToCurrency(int value) {
    return '₱${(value / 100).toStringAsFixed(2)}';
  }

  static String centavosToInputValue(int value) {
    return (value / 100).toStringAsFixed(2);
  }

  static int _dbNumToCentavos(double value) {
    final rounded = value.roundToDouble();
    final hasFractionalPart = (value - rounded).abs() > 0.000001;
    if (hasFractionalPart) {
      return (value * 100).round();
    }
    return value.round();
  }
}
