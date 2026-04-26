import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:SaktoSpend/features/shopping_session/presentation/widgets/cart_entry_sheet.dart';
import 'package:SaktoSpend/features/shopping_session/presentation/widgets/empty_cart_placeholder.dart';
import 'package:SaktoSpend/features/shopping_session/presentation/widgets/remaining_budget_card.dart';
import 'package:SaktoSpend/features/shopping_session/presentation/widgets/session_cart_list.dart';
import 'package:SaktoSpend/features/shopping_session/presentation/widgets/voice_entry_sheet.dart';
import 'package:flutter/material.dart';

part 'active_session_screen_logic.dart';

class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({
    super.key,
    required this.onBack,
    required this.onOpenScanner,
    required this.onAddManualItem,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.cartItems,
    required this.hardBudgetModeEnabled,
    required this.ocrScannerEnabled,
    this.budget,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenScanner;
  final ValueChanged<SessionCartItem> onAddManualItem;
  final void Function(int index, SessionCartItem item) onEditItem;
  final ValueChanged<int> onDeleteItem;
  final List<SessionCartItem> cartItems;
  final bool hardBudgetModeEnabled;
  final bool ocrScannerEnabled;
  final Budget? budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final totalBudget = budget?.amount ?? 64270;
    final sessionCartTotal = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final remainingBudget = totalBudget - sessionCartTotal;
    final spent = totalBudget - remainingBudget;
    final progress = totalBudget <= 0
        ? 0.0
        : (spent / totalBudget).clamp(0.0, 1.0).toDouble();
    final showItems = cartItems.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SessionTopIconButton(
                  onPressed: onBack,
                  icon: Icons.arrow_back_rounded,
                ),
                const Spacer(),
                if (hardBudgetModeEnabled) const _SessionHeaderBadge(),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget?.name ?? 'Shopping Session',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 40,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track items as you shop with label scan, voice, or quick manual entry.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    RemainingBudgetCard(
                      remainingText: _money(remainingBudget),
                      spentText: _money(spent),
                      totalText: _money(totalBudget),
                      progress: progress,
                      isNegativeRemaining: remainingBudget < 0,
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Text(
                          'Active Cart',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.surfacePrimary,
                            border: Border.all(color: tokens.borderSubtle),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: tokens.shadowColor,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            '${cartItems.length} ITEMS',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showItems
                          ? 'Your current cart, with essentials grouped first for faster review.'
                          : 'Your cart is ready for items whenever you are.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (showItems)
                      SessionCartList(
                        items: cartItems,
                        moneyFormatter: _money,
                        padding: const EdgeInsets.only(bottom: 8),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onDeleteItem: onDeleteItem,
                        onEditRequested: (index, item) async {
                          await _openEditEntrySheet(
                            context,
                            index: index,
                            item: item,
                            budgetTotal: totalBudget,
                            currentSessionTotal: sessionCartTotal,
                            hardBudgetModeEnabled: hardBudgetModeEnabled,
                            onEditItem: onEditItem,
                          );
                        },
                      )
                    else
                      const EmptyCartPlaceholder(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SessionPrimaryActionButton(
                    icon: Icons.document_scanner_outlined,
                    label: ocrScannerEnabled ? 'Scan Label' : 'Label Scan Off',
                    onPressed: ocrScannerEnabled ? onOpenScanner : null,
                  ),
                ),
                const SizedBox(width: 10),
                _SessionSquareActionButton(
                  icon: Icons.mic_none_rounded,
                  onTap: () async {
                    await _openVoiceEntrySheet(
                      context,
                      budgetTotal: totalBudget,
                      currentSessionTotal: sessionCartTotal,
                      hardBudgetModeEnabled: hardBudgetModeEnabled,
                      onAddManualItem: onAddManualItem,
                    );
                  },
                ),
                const SizedBox(width: 10),
                _SessionSquareActionButton(
                  icon: Icons.add_rounded,
                  onTap: () async {
                    await _openManualEntrySheet(
                      context,
                      budgetTotal: totalBudget,
                      currentSessionTotal: sessionCartTotal,
                      hardBudgetModeEnabled: hardBudgetModeEnabled,
                      onAddManualItem: onAddManualItem,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTopIconButton extends StatelessWidget {
  const _SessionTopIconButton({required this.onPressed, required this.icon});

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

class _SessionHeaderBadge extends StatelessWidget {
  const _SessionHeaderBadge();

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

class _SessionPrimaryActionButton extends StatelessWidget {
  const _SessionPrimaryActionButton({
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

    return SizedBox(
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: disabled
              ? tokens.surfaceElevated
              : tokens.accentStrong,
          foregroundColor: disabled
              ? tokens.textTertiary
              : tokens.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SessionSquareActionButton extends StatelessWidget {
  const _SessionSquareActionButton({
    required this.icon,
    required this.onTap,
  });

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
