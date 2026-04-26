part of 'scan_review_screen.dart';

String _extractBarcodeCode(BarcodeCapture capture) {
  return capture.barcodes
      .map((barcode) => barcode.rawValue ?? barcode.displayValue)
      .whereType<String>()
      .map((value) => value.trim())
      .firstWhere((value) => value.isNotEmpty, orElse: () => '');
}

ScannerOcrProduct? extractScannerOcrProduct(List<ScannerOcrLine> ocrLines) {
  final normalized = ocrLines
      .map(
        (line) => line.copyWith(
          text: line.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
        ),
      )
      .where((line) => line.text.isNotEmpty)
      .toList();
  if (normalized.isEmpty) {
    return null;
  }

  final priceCandidate = _extractPriceCandidate(normalized);
  final price = priceCandidate?.price;
  final name = _extractName(normalized, priceTop: priceCandidate?.line.top);

  if (name == null || price == null) {
    return null;
  }
  if (!_isReliableExtractedName(name) || !_isReliableExtractedPrice(price)) {
    return null;
  }

  return ScannerOcrProduct(name: name, price: price);
}

String? _extractName(List<ScannerOcrLine> lines, {double? priceTop}) {
  final normalized = lines.map((line) => line.text).toList();
  final firstNumericIndex = normalized.indexWhere((line) {
    return RegExp(r'\d{6,}').hasMatch(line) ||
        RegExp(r'^[\d\s\-/]+$').hasMatch(line) ||
        RegExp(r'^\d+[.,]\d{2}$').hasMatch(line);
  });

  _CandidateName? best;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final text = line.text;
    if (!_looksLikeProductName(text)) {
      continue;
    }

    var score = 0;
    final words = text.split(RegExp(r'\s+'));
    final hasQtyToken =
        RegExp(r"\b\d+\s*'?s\b", caseSensitive: false).hasMatch(text) ||
        RegExp(
          r'\b\d+\s*(pcs?|pack|ct|count)\b',
          caseSensitive: false,
        ).hasMatch(text);
    final hasLower = RegExp(r'[a-z]').hasMatch(text);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(text);
    final isAllCapsWord = RegExp(r'^[A-Z]{5,}$').hasMatch(text);

    if (words.length >= 2) score += 40;
    if (hasQtyToken) score += 28;
    if (hasLower && hasUpper) score += 18;
    if (text.length >= 6 && text.length <= 42) score += 12;
    if (i == 0) score += 18;
    if (i == 1) score += 10;
    if (firstNumericIndex > 0 && i == firstNumericIndex - 1) score += 16;
    if (firstNumericIndex > 1 && i == firstNumericIndex - 2) score += 8;
    if (priceTop != null && line.top < priceTop) score += 14;

    if (isAllCapsWord) score -= 42;
    if (words.length == 1) score -= 20;
    if (RegExp(r'\d{6,}').hasMatch(text)) score -= 30;
    if (RegExp(
      r'^\s*(?:₱|php|p)?\s*\d{1,5}(?:[.,]\d{2})\s*$',
      caseSensitive: false,
    ).hasMatch(text)) {
      score -= 52;
    }
    if (RegExp(r'\b\d+\s*(g|kg|ml|l)\b', caseSensitive: false).hasMatch(text)) {
      score -= 34;
    }
    if (RegExp(
      r'price\s*per|per\s*\d+\s*(g|kg|ml|l)|/\s*\d+\s*(g|kg|ml|l)',
      caseSensitive: false,
    ).hasMatch(text)) {
      score -= 44;
    }
    if (priceTop != null && line.top > priceTop) score -= 18;
    if (RegExp(
      r'po\s*no|serial|barcode|lot',
      caseSensitive: false,
    ).hasMatch(text)) {
      score -= 26;
    }

    if (best == null || score > best.score) {
      best = _CandidateName(name: text, score: score);
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

_PriceCandidate? _extractPriceCandidate(List<ScannerOcrLine> lines) {
  _PriceCandidate? best;

  for (final line in lines) {
    final text = line.text;
    final matches = RegExp(
      r'(?<!\d)(?:₱|php|p)?\s*(\d{1,5}(?:[.,]\d{2}))(?!\d)',
      caseSensitive: false,
    ).allMatches(text);

    for (final match in matches) {
      final raw = match.group(1);
      if (raw == null) {
        continue;
      }

      final price = MoneyUtils.parseCurrencyToCentavos(
        _normalizePriceToken(raw),
      );
      if (!_isReliableExtractedPrice(price)) {
        continue;
      }

      var score = 0;
      if (RegExp(
        r'^\s*(?:₱|php|p)?\s*\d{1,5}(?:[.,]\d{2})\s*$',
        caseSensitive: false,
      ).hasMatch(text)) {
        score += 72;
      }
      if (RegExp(r'(₱|php|\bp\b)', caseSensitive: false).hasMatch(text)) {
        score += 18;
      }
      if (text.length <= 14) {
        score += 12;
      }
      score += (line.height * 2).round().clamp(0, 60);

      if (RegExp(
        r'price\s*per|per\s*\d+\s*(g|kg|ml|l)|/\s*\d+\s*(g|kg|ml|l)',
        caseSensitive: false,
      ).hasMatch(text)) {
        score -= 90;
      }
      if (RegExp(r'promo|save|discount', caseSensitive: false).hasMatch(text)) {
        score -= 20;
      }

      if (best == null ||
          score > best.score ||
          (score == best.score && line.height > best.line.height)) {
        best = _PriceCandidate(price: price, score: score, line: line);
      }
    }
  }

  return best;
}

String _normalizePriceToken(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9,\.]'), '');
  if (cleaned.contains(',') && !cleaned.contains('.')) {
    return cleaned.replaceAll(',', '.');
  }
  return cleaned.replaceAll(',', '');
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

String _buildExtractKey(ScannerOcrProduct extracted) {
  final normalizedName = extracted.name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return '$normalizedName|${extracted.price}';
}

class ScannerOcrProduct {
  const ScannerOcrProduct({required this.name, required this.price});

  final String name;
  final int price;
}

class ScannerOcrLine {
  const ScannerOcrLine({
    required this.text,
    required this.top,
    required this.left,
    this.width = 0,
    this.height = 0,
  });

  final String text;
  final double top;
  final double left;
  final double width;
  final double height;

  ScannerOcrLine copyWith({
    String? text,
    double? top,
    double? left,
    double? width,
    double? height,
  }) {
    return ScannerOcrLine(
      text: text ?? this.text,
      top: top ?? this.top,
      left: left ?? this.left,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class _CandidateName {
  const _CandidateName({required this.name, required this.score});

  final String name;
  final int score;
}

class _PriceCandidate {
  const _PriceCandidate({
    required this.price,
    required this.score,
    required this.line,
  });

  final int price;
  final int score;
  final ScannerOcrLine line;
}
