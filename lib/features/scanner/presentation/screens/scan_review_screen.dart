import 'dart:async';

import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

part '../widgets/scan_review_entry_form.dart';
part '../widgets/scan_review_main_content.dart';
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
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final ImagePicker _imagePicker = ImagePicker();

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
  bool _manualOnlyMode = false;

  @override
  void initState() {
    super.initState();
    _manualOnlyMode = widget.initialManualEntry;
    if (widget.initialManualEntry) {
      _showEntry = true;
    }
  }

  @override
  void dispose() {
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
    final budgetRemainingBeforeEntry = totalBudget - currentSessionTotal;

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: context.appThemeTokens.backgroundCanvas,
            ),
          ),
          if (!_manualOnlyMode)
            _ScannerScreenBody(
              hasScan: hasScan,
              isProcessingCapture: _isProcessingCapture,
              hardBudgetModeEnabled: widget.hardBudgetModeEnabled,
              scannedProduct: _scannedProduct,
              helperText: _captureLabel(hasScan),
              onBackPressed: _onBackPressed,
              onOpenEntry: _openEntry,
              onRestartScanner: _restartScanner,
              onScanFromCamera: _isProcessingCapture
                  ? null
                  : () => _scanLabel(ImageSource.camera),
              onScanFromGallery: _isProcessingCapture
                  ? null
                  : () => _scanLabel(ImageSource.gallery),
            ),
          if (_showEntry)
            _ScannerEntrySheetOverlay(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
              onDismiss: _closeEntry,
              child: _EntryForm(
                isScannedDraft: hasScan,
                hardBudgetModeEnabled: widget.hardBudgetModeEnabled,
                nameController: _nameController,
                priceController: _priceController,
                categories: _categories,
                category: _category,
                quantity: _quantity,
                unit: _unit,
                isEssential: _isEssential,
                total: total,
                budgetTotal: totalBudget,
                budgetRemainingBeforeEntry: budgetRemainingBeforeEntry,
                onClose: _closeEntry,
                onChanged: () => setState(() {}),
                onCategoryChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _category = value);
                },
                onDecreaseQty: () {
                  setState(
                    () => _quantity = (_quantity - 1).clamp(1, 99).toInt(),
                  );
                },
                onIncreaseQty: () {
                  setState(
                    () => _quantity = (_quantity + 1).clamp(1, 99).toInt(),
                  );
                },
                onUnitChanged: (value) => setState(() => _unit = value),
                onEssentialChanged: (value) =>
                    setState(() => _isEssential = value),
                onConfirm: _confirmEntry,
              ),
            ),
        ],
      ),
    );
  }

  String _captureLabel(bool hasScan) {
    if (_isProcessingCapture) {
      return 'Reading the label and extracting the product details now.';
    }
    if (hasScan) {
      return 'The product name and price were extracted. Review the draft before adding it to your cart.';
    }
    return 'Use a label photo where the product name and shelf price are easy to read.';
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

  Future<ScannerOcrProduct?> _extractProductDetailsFromPath(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final ocrLines =
        recognizedText.blocks
            .expand((block) => block.lines)
            .map(
              (line) => ScannerOcrLine(
                text: line.text.trim(),
                top: line.boundingBox.top,
                left: line.boundingBox.left,
                width: line.boundingBox.width,
                height: line.boundingBox.height,
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

    return extractScannerOcrProduct(ocrLines);
  }

  Future<void> _scanLabel(ImageSource source) async {
    if (_showEntry || _isProcessingCapture) {
      return;
    }

    setState(() => _isProcessingCapture = true);

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (!mounted) {
        return;
      }
      if (picked == null) {
        setState(() => _isProcessingCapture = false);
        return;
      }

      final extracted = await _extractProductDetailsFromPath(picked.path);
      if (!mounted) {
        return;
      }
      if (extracted == null) {
        setState(() => _isProcessingCapture = false);
        AppSnackbars.showError(
          context,
          'No product name and price were detected from that photo.',
        );
        return;
      }

      _applyExtractedProduct(extracted);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isProcessingCapture = false);
      AppSnackbars.showError(context, 'Failed to scan product label.');
    }
  }

  void _applyExtractedProduct(ScannerOcrProduct extracted) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingCapture = false;
      _scannedProduct = _ScannedProduct(
        name: extracted.name,
        category: _category,
        unitPrice: extracted.price,
      );
      _nameController.text = extracted.name;
      _priceController.text = MoneyUtils.centavosToInputValue(extracted.price);
      _quantity = 1;
      _unit = 'PC';
      _isEssential = false;
    });
  }

  void _openEntry() {
    setState(() => _showEntry = true);
  }

  void _closeEntry() {
    if (_manualOnlyMode) {
      widget.onBack();
      return;
    }
    setState(() => _showEntry = false);
  }

  void _restartScanner() {
    setState(() {
      _isProcessingCapture = false;
      _scannedProduct = null;
      _nameController.clear();
      _priceController.clear();
      _category = 'Groceries';
      _quantity = 1;
      _unit = 'PC';
      _isEssential = false;
      _showEntry = false;
    });
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
      source: _manualOnlyMode
          ? SessionCartItemSource.manual
          : SessionCartItemSource.labelScan,
    );
    widget.onAddToCart(item);
  }
}

class _ScannedProduct {
  const _ScannedProduct({
    required this.name,
    required this.category,
    required this.unitPrice,
  });

  final String name;
  final String category;
  final int unitPrice;
}

String _money(int value) => MoneyUtils.centavosToCurrency(value);
