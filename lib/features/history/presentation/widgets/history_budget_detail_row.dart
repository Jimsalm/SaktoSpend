import 'package:budget_tracker/core/utils/utils.dart';
import 'package:budget_tracker/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:flutter/material.dart';

class HistoryBudgetDetailRow extends StatelessWidget {
  const HistoryBudgetDetailRow({super.key, required this.item});

  final SessionCartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0EEEA))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7C776E),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                MoneyUtils.centavosToCurrency(item.unitPrice),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                MoneyUtils.centavosToCurrency(item.totalPrice),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
