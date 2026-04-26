import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyCartPlaceholder extends StatelessWidget {
  const EmptyCartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
              height: 112,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 34,
                    top: 26,
                    child: _FloatIconCard(icon: Icons.mic_none_rounded),
                  ),
                  Positioned(
                    right: 34,
                    top: 6,
                    child: _FloatIconCard(
                      icon: Icons.document_scanner_outlined,
                    ),
                  ),
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: tokens.surfaceSecondary,
                      borderRadius: BorderRadius.circular(22),
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
            const SizedBox(height: 8),
            Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a product label, use voice entry, or tap the plus button to start building this shopping session.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: tokens.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
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
      ),
    );
  }
}

class _FloatIconCard extends StatelessWidget {
  const _FloatIconCard({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: tokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 22, color: tokens.textSecondary),
    );
  }
}
