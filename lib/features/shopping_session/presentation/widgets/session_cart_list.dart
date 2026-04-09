import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:flutter/material.dart';

class SessionCartList extends StatelessWidget {
  const SessionCartList({
    super.key,
    required this.items,
    required this.moneyFormatter,
    required this.onEditRequested,
    required this.onDeleteItem,
  });

  final List<SessionCartItem> items;
  final String Function(int value) moneyFormatter;
  final Future<void> Function(int index, SessionCartItem item) onEditRequested;
  final ValueChanged<int> onDeleteItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayItems = items.asMap().entries.toList()
      ..sort((a, b) {
        if (a.value.isEssential == b.value.isEssential) {
          return a.key.compareTo(b.key);
        }
        return a.value.isEssential ? -1 : 1;
      });
    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: displayItems.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = displayItems[index];
          final item = entry.value;
          final originalIndex = entry.key;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _iconForCategory(item.category),
                    size: 20,
                    color: const Color(0xFF44423D),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF66635C),
                        ),
                      ),
                      if (item.isEssential)
                        Text(
                          'Essential',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF151515),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      moneyFormatter(item.totalPrice),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'QTY: ${item.quantity} ${item.unit}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<_CartItemMenuAction>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (action) async {
                    if (action == _CartItemMenuAction.edit) {
                      await onEditRequested(originalIndex, item);
                      return;
                    }
                    onDeleteItem(originalIndex);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _CartItemMenuAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _CartItemMenuAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _CartItemMenuAction { edit, delete }

IconData _iconForCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('beverage')) return Icons.local_drink_outlined;
  if (normalized.contains('coffee')) return Icons.coffee;
  if (normalized.contains('dairy')) return Icons.egg_alt_outlined;
  if (normalized.contains('bakery')) return Icons.bakery_dining;
  if (normalized.contains('transport')) return Icons.directions_bus_outlined;
  if (normalized.contains('grocery')) return Icons.shopping_basket_outlined;
  return Icons.inventory_2_outlined;
}
