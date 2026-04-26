part of '../screens/scan_review_screen.dart';

class _ScannerScreenBody extends StatelessWidget {
  const _ScannerScreenBody({
    required this.hasScan,
    required this.isProcessingCapture,
    required this.hardBudgetModeEnabled,
    required this.scannedProduct,
    required this.helperText,
    required this.onBackPressed,
    required this.onOpenEntry,
    required this.onRestartScanner,
    required this.onScanFromCamera,
    required this.onScanFromGallery,
  });

  final bool hasScan;
  final bool isProcessingCapture;
  final bool hardBudgetModeEnabled;
  final _ScannedProduct? scannedProduct;
  final String helperText;
  final VoidCallback onBackPressed;
  final VoidCallback onOpenEntry;
  final VoidCallback onRestartScanner;
  final VoidCallback? onScanFromCamera;
  final VoidCallback? onScanFromGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ScannerTopIconButton(
                          onPressed: onBackPressed,
                          icon: Icons.arrow_back_rounded,
                        ),
                        const Spacer(),
                        if (hardBudgetModeEnabled) const _ScannerHeaderBadge(),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Label Scanner',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 40,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a clear label photo and review the extracted product name and price before adding it to your cart.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ScannerHeroCard(
                      hasScan: hasScan,
                      isProcessing: isProcessingCapture,
                      product: scannedProduct,
                      helperText: helperText,
                      onReviewTap: hasScan ? onOpenEntry : null,
                    ),
                    const SizedBox(height: 14),
                    if (hasScan && scannedProduct != null)
                      _ScannedProductCard(
                        product: scannedProduct!,
                        onTap: onOpenEntry,
                        onReviewTap: onOpenEntry,
                      )
                    else
                      const _ScannerGuideCard(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: hasScan
                      ? Row(
                          children: [
                            Expanded(
                              child: _ScannerPrimaryActionButton(
                                icon: Icons.edit_note_rounded,
                                label: 'Review Entry',
                                onPressed: onOpenEntry,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _ScannerSquareActionButton(
                              icon: Icons.refresh_rounded,
                              onTap: onRestartScanner,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _ScannerPrimaryActionButton(
                                icon: isProcessingCapture
                                    ? Icons.hourglass_top_rounded
                                    : Icons.photo_camera_outlined,
                                label: isProcessingCapture
                                    ? 'Reading Label...'
                                    : 'Take Photo',
                                onPressed: onScanFromCamera,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ScannerSecondaryActionButton(
                                icon: Icons.photo_library_outlined,
                                label: 'Choose Photo',
                                onPressed: onScanFromGallery,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScannerEntrySheetOverlay extends StatelessWidget {
  const _ScannerEntrySheetOverlay({
    required this.maxHeight,
    required this.onDismiss,
    required this.child,
  });

  final double maxHeight;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.24),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 460,
                maxHeight: maxHeight,
              ),
              decoration: BoxDecoration(
                color: tokens.backgroundCanvas,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: tokens.shadowColor,
                    blurRadius: 28,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerTopIconButton extends StatelessWidget {
  const _ScannerTopIconButton({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: tokens.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _ScannerHeaderBadge extends StatelessWidget {
  const _ScannerHeaderBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.textPrimary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'HARD MODE ON',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerHeroCard extends StatelessWidget {
  const _ScannerHeroCard({
    required this.hasScan,
    required this.isProcessing,
    required this.product,
    required this.helperText,
    this.onReviewTap,
  });

  final bool hasScan;
  final bool isProcessing;
  final _ScannedProduct? product;
  final String helperText;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final headline = isProcessing
        ? 'Reading Label'
        : hasScan
            ? 'Label Ready'
            : 'Scan Product Label';
    final statusLabel = isProcessing
        ? 'Processing'
        : hasScan
            ? 'Ready'
            : 'Awaiting Photo';
    final statusColor = isProcessing
        ? const Color(0xFF4A66A6)
        : hasScan
            ? const Color(0xFF5F950D)
            : tokens.textSecondary;
    final statusBackground = isProcessing
        ? const Color(0xFFE9F0FF)
        : hasScan
            ? tokens.accentSoft
            : tokens.surfaceSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(0.88, -0.06),
          radius: 1.08,
          colors: [
            tokens.accentSoft.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.97),
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LABEL OCR',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  headline,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  helperText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ScannerTag(
                      icon: Icons.document_scanner_outlined,
                      label: statusLabel,
                      backgroundColor: statusBackground,
                      foregroundColor: statusColor,
                    ),
                    if (hasScan && product != null)
                      _ScannerTag(
                        icon: Icons.sell_outlined,
                        label: product!.category,
                        backgroundColor: tokens.surfaceSecondary,
                        foregroundColor: tokens.textSecondary,
                      ),
                  ],
                ),
                if (hasScan && onReviewTap != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: onReviewTap,
                    style: TextButton.styleFrom(
                      foregroundColor: tokens.textPrimary,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Review extracted entry'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              shape: BoxShape.circle,
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Center(
              child: isProcessing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: tokens.textPrimary,
                      ),
                    )
                  : Icon(
                      hasScan
                          ? Icons.check_circle_outline_rounded
                          : Icons.document_scanner_outlined,
                      color: hasScan
                          ? const Color(0xFF69A80D)
                          : tokens.textPrimary,
                      size: 30,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerGuideCard extends StatelessWidget {
  const _ScannerGuideCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.tips_and_updates_outlined,
              color: tokens.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Results',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep the label flat, make sure the product name and price are both visible, and avoid glare over the printed text.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerPrimaryActionButton extends StatelessWidget {
  const _ScannerPrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final disabled = onPressed == null;

    return _ScannerActionButtonSurface(
      onTap: onPressed,
      backgroundColor: disabled ? tokens.surfaceElevated : tokens.accentStrong,
      foregroundColor: disabled ? tokens.textTertiary : tokens.textPrimary,
      borderColor: disabled ? tokens.surfaceElevated : tokens.accentStrong,
      child: _ScannerActionButtonContent(
        icon: icon,
        label: label,
        foregroundColor: disabled ? tokens.textTertiary : tokens.textPrimary,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScannerSecondaryActionButton extends StatelessWidget {
  const _ScannerSecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return _ScannerActionButtonSurface(
      onTap: onPressed,
      backgroundColor: tokens.surfacePrimary,
      foregroundColor: onPressed == null
          ? tokens.textTertiary
          : tokens.textPrimary,
      borderColor: tokens.borderSubtle,
      child: _ScannerActionButtonContent(
        icon: icon,
        label: label,
        foregroundColor: onPressed == null
            ? tokens.textTertiary
            : tokens.textPrimary,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScannerActionButtonSurface extends StatelessWidget {
  const _ScannerActionButtonSurface({
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.child,
  });

  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    final disabled = onTap == null;

    return SizedBox(
      height: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: tokens.shadowColor,
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foregroundColor),
              child: IconTheme.merge(
                data: IconThemeData(color: foregroundColor),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerActionButtonContent extends StatelessWidget {
  const _ScannerActionButtonContent({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    this.textStyle,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: foregroundColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyle?.copyWith(
                color: foregroundColor,
                fontSize: 15,
                height: 1.08,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerSquareActionButton extends StatelessWidget {
  const _ScannerSquareActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return SizedBox(
      width: 58,
      height: 58,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: tokens.surfacePrimary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: tokens.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadowColor,
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: tokens.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _ScannedProductCard extends StatelessWidget {
  const _ScannedProductCard({
    required this.product,
    required this.onTap,
    required this.onReviewTap,
  });

  final _ScannedProduct product;
  final VoidCallback onTap;
  final VoidCallback onReviewTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: tokens.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 26,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Extracted from the latest label photo and ready for review.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ScannerTag(
                            icon: Icons.sell_outlined,
                            label: product.category,
                            backgroundColor: tokens.surfaceSecondary,
                            foregroundColor: tokens.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(product.unitPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onReviewTap,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.accentStrong,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: tokens.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerTag extends StatelessWidget {
  const _ScannerTag({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
