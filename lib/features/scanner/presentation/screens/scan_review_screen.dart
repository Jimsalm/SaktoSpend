import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'scan_review_screen_logic.dart';

class ScanReviewScreen extends StatefulWidget {
  const ScanReviewScreen({
    super.key,
    required this.onBack,
    required this.onAddToCart,
    required this.hardBudgetModeEnabled,
    this.budget,
    this.existingCartItems = const <SessionCartItem>[],
    this.initialManualEntry = false,
  });

  final VoidCallback onBack;
  final ValueChanged<SessionCartItem> onAddToCart;
  final bool hardBudgetModeEnabled;
  final Budget? budget;
  final List<SessionCartItem> existingCartItems;
  final bool initialManualEntry;

  @override
  State<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  static const Duration _captureCooldown = Duration(milliseconds: 550);
  static const int _requiredStableDetections = 2;

  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    returnImage: true,
  );
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _categories = const [
    'Groceries',
    'Beverage',
    'Pantry & Grains',
    'Dairy',
    'Lifestyle',
  ];

  _ScannedProduct? _scannedProduct;
  String _category = 'Groceries';
  String _unit = 'PC';
  int _quantity = 1;
  bool _isEssential = false;
  bool _showEntry = false;
  bool _isProcessingCapture = false;
  bool _isCameraStopped = false;
  bool _manualOnlyMode = false;
  DateTime? _lastCaptureAt;
  String? _lastExtractKey;
  int _stableExtractHits = 0;

  @override
  void initState() {
    super.initState();
    _manualOnlyMode = widget.initialManualEntry;
    if (widget.initialManualEntry) {
      _showEntry = true;
      _isCameraStopped = true;
      unawaited(_cameraController.stop());
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    unawaited(_textRecognizer.close());
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasScan = _scannedProduct != null;
    final total = _unitPrice * _quantity;
    final currentSessionTotal = widget.existingCartItems.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final totalBudget = widget.budget?.amount ?? 0;
    final baseRemaining = totalBudget;
    final budgetRemainingBeforeEntry = baseRemaining - currentSessionTotal;

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: _manualOnlyMode
                ? const ColoredBox(color: Color(0xFFF2F0EC))
                : MobileScanner(
                    controller: _cameraController,
                    onDetect: _onDetect,
                  ),
          ),
          if (!_manualOnlyMode)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.34),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.24),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 10,
            top: 10,
            child: IconButton.filledTonal(
              onPressed: _onBackPressed,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.30),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          if (!_manualOnlyMode)
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 24, 34, 160),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 320,
                        minHeight: 220,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _captureLabel(hasScan),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_manualOnlyMode && hasScan)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
              child: _ScannedProductCard(
                product: _scannedProduct!,
                onTap: _openEntry,
                onAddTap: _openEntry,
              ),
            )
          else if (!_manualOnlyMode)
            Positioned(
              right: 14,
              bottom: 22,
              child: FilledButton.icon(
                onPressed: _openManualEntry,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Manual Entry'),
              ),
            ),
          if (!_manualOnlyMode && hasScan)
            Positioned(
              left: 14,
              bottom: 22,
              child: OutlinedButton.icon(
                onPressed: _restartScanner,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  backgroundColor: Colors.black.withValues(alpha: 0.25),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
              ),
            ),
          if (_showEntry)
            Positioned.fill(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeEntry,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 420,
                        maxHeight: MediaQuery.of(context).size.height * 0.88,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F7F4),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        child: _EntryForm(
                          nameController: _nameController,
                          priceController: _priceController,
                          categories: _categories,
                          category: _category,
                          quantity: _quantity,
                          unit: _unit,
                          isEssential: _isEssential,
                          total: total,
                          budgetTotal: totalBudget,
                          budgetRemainingBeforeEntry:
                              budgetRemainingBeforeEntry,
                          onClose: _closeEntry,
                          onChanged: () => setState(() {}),
                          onCategoryChanged: (value) {
                            if (value == null) return;
                            setState(() => _category = value);
                          },
                          onDecreaseQty: () {
                            setState(
                              () => _quantity = (_quantity - 1)
                                  .clamp(1, 99)
                                  .toInt(),
                            );
                          },
                          onIncreaseQty: () {
                            setState(
                              () => _quantity = (_quantity + 1)
                                  .clamp(1, 99)
                                  .toInt(),
                            );
                          },
                          onUnitChanged: (value) =>
                              setState(() => _unit = value),
                          onEssentialChanged: (value) =>
                              setState(() => _isEssential = value),
                          onConfirm: _confirmEntry,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _captureLabel(bool hasScan) {
    if (_isProcessingCapture) return 'Reading product details...';
    if (!hasScan && _stableExtractHits > 0) {
      return 'Hold steady ($_stableExtractHits/$_requiredStableDetections)';
    }
    if (hasScan) return 'Product detected';
    return 'Align product label inside frame';
  }

  int get _unitPrice =>
      MoneyUtils.parseCurrencyToCentavos(_priceController.text);

  void _onBackPressed() {
    if (_showEntry) {
      _closeEntry();
      return;
    }
    widget.onBack();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_showEntry || _isProcessingCapture || _isCameraStopped) {
      return;
    }
    final now = DateTime.now();
    final last = _lastCaptureAt;
    if (last != null && now.difference(last) < _captureCooldown) {
      return;
    }
    _lastCaptureAt = now;
    unawaited(_handleCapture(capture));
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    final imageBytes = capture.image;
    if (imageBytes == null || imageBytes.isEmpty) {
      return;
    }
    setState(() => _isProcessingCapture = true);

    try {
      final extracted = await _extractProductDetails(imageBytes);
      if (!mounted) return;

      if (extracted == null) {
        _stableExtractHits = 0;
        _lastExtractKey = null;
        setState(() => _isProcessingCapture = false);
        return;
      }

      final extractKey = _buildExtractKey(extracted);
      if (extractKey == _lastExtractKey) {
        _stableExtractHits += 1;
      } else {
        _lastExtractKey = extractKey;
        _stableExtractHits = 1;
      }
      if (_stableExtractHits < _requiredStableDetections) {
        setState(() => _isProcessingCapture = false);
        return;
      }

      await _cameraController.stop();
      if (!mounted) return;

      setState(() {
        _isCameraStopped = true;
        _isProcessingCapture = false;
        _scannedProduct = _ScannedProduct(
          code: _extractBarcodeCode(capture),
          name: extracted.name,
          category: _category,
          unitPrice: extracted.price,
          lastScanLabel: 'just now',
        );
        _nameController.text = extracted.name;
        _priceController.text = MoneyUtils.centavosToInputValue(
          extracted.price,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessingCapture = false);
    }
  }

  Future<_ExtractedProduct?> _extractProductDetails(Uint8List bytes) async {
    final tempFile = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}scan_${DateTime.now().microsecondsSinceEpoch}.png',
    );

    await tempFile.writeAsBytes(bytes, flush: true);
    try {
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final ocrLines =
          recognizedText.blocks
              .expand((block) => block.lines)
              .map(
                (line) => _OcrLine(
                  text: line.text.trim(),
                  top: line.boundingBox.top,
                  left: line.boundingBox.left,
                ),
              )
              .where((line) => line.text.isNotEmpty)
              .toList()
            ..sort((a, b) {
              final topCompare = a.top.compareTo(b.top);
              if (topCompare != 0) {
                return topCompare;
              }
              return a.left.compareTo(b.left);
            });

      final lines = ocrLines.map((line) => line.text).toList();
      final price = _extractPrice(lines.join(' '));
      final name = _extractName(lines);

      if (name == null || price == null) {
        return null;
      }
      if (!_isReliableExtractedName(name) || !_isReliableExtractedPrice(price)) {
        return null;
      }

      return _ExtractedProduct(
        name: name,
        price: price,
      );
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  void _openManualEntry() {
    _resetScannerStability();
    setState(() {
      _scannedProduct = null;
      _nameController.clear();
      _priceController.clear();
      _category = 'Groceries';
      _quantity = 1;
      _unit = 'PC';
      _isEssential = false;
      _showEntry = true;
    });
    _isCameraStopped = true;
    unawaited(_cameraController.stop());
  }

  void _openEntry() {
    setState(() => _showEntry = true);
    _isCameraStopped = true;
    unawaited(_cameraController.stop());
  }

  void _closeEntry() {
    if (_manualOnlyMode) {
      widget.onBack();
      return;
    }
    setState(() => _showEntry = false);
  }

  void _restartScanner() {
    _resetScannerStability();
    setState(() {
      _isProcessingCapture = false;
      _isCameraStopped = false;
      _scannedProduct = null;
      _nameController.clear();
      _priceController.clear();
      _category = 'Groceries';
      _quantity = 1;
      _unit = 'PC';
      _isEssential = false;
    });
    unawaited(_cameraController.start());
  }

  void _resetScannerStability() {
    _lastCaptureAt = null;
    _lastExtractKey = null;
    _stableExtractHits = 0;
  }

  void _confirmEntry() {
    final rawName = _nameController.text.trim();
    final name = rawName.isNotEmpty ? rawName : 'Manual Item';
    final totalBudget = widget.budget?.amount ?? 0;
    final currentSessionTotal = widget.existingCartItems.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final newEntryTotal = _unitPrice * _quantity;
    final projectedTotal = currentSessionTotal + newEntryTotal;

    if (widget.hardBudgetModeEnabled && projectedTotal > totalBudget) {
      AppSnackbars.showError(
        context,
        'Hard Budget Mode is enabled. This entry exceeds the remaining budget.',
      );
      return;
    }

    final item = SessionCartItem(
      name: name,
      category: _category,
      unitPrice: _unitPrice,
      quantity: _quantity,
      unit: _unit,
      isEssential: _isEssential,
    );
    widget.onAddToCart(item);
  }
}

class _ScannedProductCard extends StatelessWidget {
  const _ScannedProductCard({
    required this.product,
    required this.onTap,
    required this.onAddTap,
  });

  final _ScannedProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      color: const Color(0xFFF8F8F6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF66635D),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Last scanned ${product.lastScanLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF7C776F),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _money(product.unitPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryForm extends StatelessWidget {
  const _EntryForm({
    required this.nameController,
    required this.priceController,
    required this.categories,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.isEssential,
    required this.total,
    required this.budgetTotal,
    required this.budgetRemainingBeforeEntry,
    required this.onClose,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onDecreaseQty,
    required this.onIncreaseQty,
    required this.onUnitChanged,
    required this.onEssentialChanged,
    required this.onConfirm,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final List<String> categories;
  final String category;
  final int quantity;
  final String unit;
  final bool isEssential;
  final int total;
  final int budgetTotal;
  final int budgetRemainingBeforeEntry;
  final VoidCallback onClose;
  final VoidCallback onChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onDecreaseQty;
  final VoidCallback onIncreaseQty;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<bool> onEssentialChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = budgetRemainingBeforeEntry - total;
    final safeBudgetBase = budgetTotal > 0
        ? budgetTotal
        : (budgetRemainingBeforeEntry > 0 ? budgetRemainingBeforeEntry : 0);
    final progress = safeBudgetBase <= 0
        ? 0.0
        : (remaining / safeBudgetBase).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Entry Details',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 30),
            ),
            const Spacer(),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          ],
        ),
        Text(
          'MANUAL DRAFT',
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF75726C),
          ),
        ),
        const SizedBox(height: 14),
        _label(theme, 'PRODUCT IDENTITY'),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            hintText: 'e.g. Organic Almond Milk',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, 'CATEGORY'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: categories
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: onCategoryChanged,
                    decoration: const InputDecoration(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, 'UNIT PRICE'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    onChanged: (_) => onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      prefixText: '${MoneyUtils.currencySymbol}  ',
                      hintText: '0.00',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, 'QUANTITY'),
                  const SizedBox(height: 6),
                  _inputLike(
                    child: Row(
                      children: [
                        _tapLabel('-', onDecreaseQty, theme),
                        const Spacer(),
                        Text(
                          '$quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 26,
                          ),
                        ),
                        const Spacer(),
                        _tapLabel('+', onIncreaseQty, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, 'UNIT'),
                  const SizedBox(height: 6),
                  _inputLike(
                    child: Row(
                      children: [
                        Expanded(
                          child: _segButton(
                            'PC',
                            unit == 'PC',
                            theme,
                            () => onUnitChanged('PC'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _segButton(
                            'KG',
                            unit == 'KG',
                            theme,
                            () => onUnitChanged('KG'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _inputLike(
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                'ESSENTIAL ITEM',
                style: theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Switch(
                value: isEssential,
                onChanged: onEssentialChanged,
                activeTrackColor: Colors.black,
                activeThumbColor: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'BUDGET IMPACT',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Left',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: progress,
                  backgroundColor: const Color(0xFF454545),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remaining: ${remaining < 0 ? '-' : ''}${_money(remaining.abs())}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD7D7D7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _label(theme, 'TOTAL COST'),
        const SizedBox(height: 4),
        Row(
          children: [
            const Spacer(),
            Text(
              _money(total),
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 44),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Confirm Entry',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannedProduct {
  const _ScannedProduct({
    required this.code,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.lastScanLabel,
  });

  final String code;
  final String name;
  final String category;
  final int unitPrice;
  final String lastScanLabel;
}

Widget _label(ThemeData theme, String text) {
  return Text(
    text,
    style: theme.textTheme.bodyMedium?.copyWith(
      letterSpacing: 1.7,
      fontWeight: FontWeight.w700,
    ),
  );
}

Widget _inputLike({required Widget child}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFEAE7E2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

Widget _tapLabel(String text, VoidCallback onTap, ThemeData theme) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(fontSize: 26),
      ),
    ),
  );
}

Widget _segButton(
  String label,
  bool selected,
  ThemeData theme,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(5),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.black : const Color(0xFFE9E6E1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : const Color(0xFF141414),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

String _money(int value) => MoneyUtils.centavosToCurrency(value);
