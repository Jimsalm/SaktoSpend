part of 'scan_review_screen.dart';

String _extractBarcodeCode(BarcodeCapture capture) {
  return capture.barcodes
      .map((barcode) => barcode.rawValue ?? barcode.displayValue)
      .whereType<String>()
      .map((value) => value.trim())
      .firstWhere((value) => value.isNotEmpty, orElse: () => '');
}

String? _extractName(List<String> lines) {
  final normalized = lines
      .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (normalized.isEmpty) {
    return null;
  }

  final firstNumericIndex = normalized.indexWhere((line) {
    return RegExp(r'\d{6,}').hasMatch(line) ||
        RegExp(r'^[\d\s\-/]+$').hasMatch(line) ||
        RegExp(r'^\d+[.,]\d{2}$').hasMatch(line);
  });

  _CandidateName? best;
  for (var i = 0; i < normalized.length; i++) {
    final line = normalized[i];
    if (!_looksLikeProductName(line)) {
      continue;
    }

    var score = 0;
    final words = line.split(RegExp(r'\s+'));
    final hasQtyToken =
        RegExp(r"\b\d+\s*'?s\b", caseSensitive: false).hasMatch(line) ||
        RegExp(
          r'\b\d+\s*(pcs?|pack|ct|count)\b',
          caseSensitive: false,
        ).hasMatch(line);
    final hasLower = RegExp(r'[a-z]').hasMatch(line);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(line);
    final isAllCapsWord = RegExp(r'^[A-Z]{5,}$').hasMatch(line);

    if (words.length >= 2) score += 40;
    if (hasQtyToken) score += 28;
    if (hasLower && hasUpper) score += 18;
    if (line.length >= 6 && line.length <= 42) score += 12;
    if (firstNumericIndex > 0 && i == firstNumericIndex - 1) score += 16;
    if (firstNumericIndex > 1 && i == firstNumericIndex - 2) score += 8;

    if (isAllCapsWord) score -= 42;
    if (words.length == 1) score -= 20;
    if (RegExp(r'\d{6,}').hasMatch(line)) score -= 30;
    if (RegExp(r'po\s*no|serial|barcode|lot', caseSensitive: false).hasMatch(
      line,
    )) {
      score -= 26;
    }

    if (best == null || score > best.score) {
      best = _CandidateName(name: line, score: score);
    }
  }

  return best?.name;
}

bool _looksLikeProductName(String line) {
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(line);
  if (!hasLetter) return false;
  if (RegExp(r'^\d+[.,]\d{2}$').hasMatch(line)) return false;
  if (RegExp(r'^[\d\s\-\/]+$').hasMatch(line)) return false;
  if (RegExp(r'\d{6,}').hasMatch(line)) return false;
  if (line.length < 3) return false;
  return true;
}

int? _extractPrice(String text) {
  final matches = RegExp(r'(?<!\d)(\d{1,5}(?:[.,]\d{2}))(?!\d)')
      .allMatches(text)
      .map((match) => match.group(1))
      .whereType<String>()
      .toList();
  if (matches.isEmpty) {
    return null;
  }
  final raw = matches.last.replaceAll(',', '.');
  return MoneyUtils.parseCurrencyToCentavos(raw);
}

bool _isReliableExtractedName(String name) {
  final trimmed = name.trim();
  if (trimmed.length < 3 || trimmed.length > 60) {
    return false;
  }
  if (RegExp(
    r'po\s*no|serial|barcode|lot|invoice|receipt',
    caseSensitive: false,
  ).hasMatch(trimmed)) {
    return false;
  }
  if (RegExp(r'^\d+$').hasMatch(trimmed)) {
    return false;
  }
  return RegExp(r'[A-Za-z]').hasMatch(trimmed);
}

bool _isReliableExtractedPrice(int price) {
  if (price <= 0) {
    return false;
  }
  // Ignore obviously noisy OCR values (e.g., accidental huge readings).
  return price <= 50000000; // up to 500,000.00
}

String _buildExtractKey(_ExtractedProduct extracted) {
  final normalizedName = extracted.name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return '$normalizedName|${extracted.price}';
}

class _ExtractedProduct {
  const _ExtractedProduct({required this.name, required this.price});

  final String name;
  final int price;
}

class _OcrLine {
  const _OcrLine({required this.text, required this.top, required this.left});

  final String text;
  final double top;
  final double left;
}

class _CandidateName {
  const _CandidateName({required this.name, required this.score});

  final String name;
  final int score;
}
