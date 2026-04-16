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
    final totalBudget = budget?.amount ?? 64270;
    final sessionCartTotal = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final remainingBudget = totalBudget - sessionCartTotal;
    final spent = totalBudget - remainingBudget;
    final progress = totalBudget <= 0
        ? 0.0
        : (spent / totalBudget).clamp(0.0, 1.0);
    final showItems = cartItems.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                if (hardBudgetModeEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HARD MODE ON',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            RemainingBudgetCard(
              remainingText: _money(remainingBudget),
              spentText: _money(spent),
              totalText: _money(totalBudget),
              progress: progress,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Active Cart',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E7E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${cartItems.length} ITEMS',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: showItems
                  ? SessionCartList(
                      items: cartItems,
                      moneyFormatter: _money,
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
                  : const EmptyCartPlaceholder(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: ocrScannerEnabled ? onOpenScanner : null,
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: Text(
                        ocrScannerEnabled ? 'Scan Barcode' : 'OCR Disabled',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE4E1DC),
                        disabledForegroundColor: const Color(0xFF8F8A81),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        textStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Material(
                    color: const Color(0xFFE4E1DC),
                    borderRadius: BorderRadius.circular(7),
                    child: InkWell(
                      onTap: () async {
                        await _openVoiceEntrySheet(
                          context,
                          budgetTotal: totalBudget,
                          currentSessionTotal: sessionCartTotal,
                          hardBudgetModeEnabled: hardBudgetModeEnabled,
                          onAddManualItem: onAddManualItem,
                        );
                      },
                      borderRadius: BorderRadius.circular(7),
                      child: const Center(
                        child: Icon(
                          Icons.mic_none,
                          size: 21,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Material(
                    color: const Color(0xFFE4E1DC),
                    borderRadius: BorderRadius.circular(7),
                    child: InkWell(
                      onTap: () async {
                        await _openManualEntrySheet(
                          context,
                          budgetTotal: totalBudget,
                          currentSessionTotal: sessionCartTotal,
                          hardBudgetModeEnabled: hardBudgetModeEnabled,
                          onAddManualItem: onAddManualItem,
                        );
                      },
                      borderRadius: BorderRadius.circular(7),
                      child: const Center(
                        child: Icon(Icons.add, size: 22, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
