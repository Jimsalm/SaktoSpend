import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyCartPlaceholder extends StatelessWidget {
  const EmptyCartPlaceholder({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final heroHeight = compact ? 88.0 : 112.0;
    final basketSize = compact ? 74.0 : 86.0;
    final titleFontSize = compact ? 24.0 : 28.0;
    final outerPadding = compact
        ? const EdgeInsets.fromLTRB(20, 22, 20, 20)
        : const EdgeInsets.fromLTRB(24, 28, 24, 24);
    final tipPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 12);

    return Container(
      width: double.infinity,
      padding: outerPadding,
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: compact ? 20 : 34,
                  top: compact ? 18 : 26,
                  child: _FloatIconCard(
                    icon: Icons.mic_none_rounded,
                    compact: compact,
                  ),
                ),
                Positioned(
                  right: compact ? 20 : 34,
                  top: compact ? 4 : 6,
                  child: _FloatIconCard(
                    icon: Icons.document_scanner_outlined,
                    compact: compact,
                  ),
                ),
                Container(
                  width: basketSize,
                  height: basketSize,
                  decoration: BoxDecoration(
                    color: tokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(compact ? 20 : 22),
                  ),
                  child: const Icon(
                    Icons.shopping_basket_outlined,
                    size: 40,
                    color: Color(0xFF69A80D),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            'Your cart is empty',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: titleFontSize,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a product label, use voice entry, or tap the plus button to start building this shopping session.',
            textAlign: TextAlign.center,
            style: (compact
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyLarge)
                ?.copyWith(
                  color: tokens.textSecondary,
                ),
          ),
          SizedBox(height: compact ? 14 : 18),
          Container(
            width: double.infinity,
            padding: tipPadding,
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: compact ? 16 : 18,
                  color: tokens.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Essentials stay grouped at the top once you begin adding items.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w600,
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
}

class _FloatIconCard extends StatelessWidget {
  const _FloatIconCard({
    required this.icon,
    required this.compact,
  });

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Container(
      width: compact ? 44 : 52,
      height: compact ? 44 : 52,
      decoration: BoxDecoration(
        color: tokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: compact ? 20 : 22,
        color: tokens.textSecondary,
      ),
    );
  }
}
