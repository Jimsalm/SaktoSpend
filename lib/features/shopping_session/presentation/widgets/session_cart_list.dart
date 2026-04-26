import 'package:SaktoSpend/core/theme/app_theme.dart';
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
    final tokens = context.appThemeTokens;
    final displayItems = items.asMap().entries.toList()
      ..sort((a, b) {
        if (a.value.isEssential == b.value.isEssential) {
          return a.key.compareTo(b.key);
        }
        return a.value.isEssential ? -1 : 1;
      });
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: displayItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = displayItems[index];
        final item = entry.value;
        final originalIndex = entry.key;
        final sourceLabel = _labelForSource(item.source);
        final sourceTone = _toneForSource(item.source, tokens);

        return Container(
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
                    _iconForCategory(item.category),
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
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SessionMetaChip(
                            icon: _sourceIcon(item.source),
                            label: sourceLabel,
                            backgroundColor: sourceTone.$1,
                            foregroundColor: sourceTone.$2,
                          ),
                          _SessionMetaChip(
                            icon: Icons.sell_outlined,
                            label: item.category,
                            backgroundColor: tokens.surfaceSecondary,
                            foregroundColor: tokens.textSecondary,
                          ),
                          if (item.isEssential)
                            _SessionMetaChip(
                              icon: Icons.shield_rounded,
                              label: 'Essential',
                              backgroundColor: tokens.accentSoft,
                              foregroundColor: const Color(0xFF5F950D),
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
                    PopupMenuButton<_CartItemMenuAction>(
                      padding: EdgeInsets.zero,
                      color: tokens.surfacePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        size: 22,
                        color: tokens.textSecondary,
                      ),
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
                    const SizedBox(height: 2),
                    Text(
                      moneyFormatter(item.totalPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _CartItemMenuAction { edit, delete }

class _SessionMetaChip extends StatelessWidget {
  const _SessionMetaChip({
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

String _labelForSource(SessionCartItemSource source) {
  switch (source) {
    case SessionCartItemSource.manual:
      return 'Manual';
    case SessionCartItemSource.voice:
      return 'Voice';
    case SessionCartItemSource.labelScan:
      return 'Label Scan';
  }
}

IconData _sourceIcon(SessionCartItemSource source) {
  switch (source) {
    case SessionCartItemSource.manual:
      return Icons.edit_note_rounded;
    case SessionCartItemSource.voice:
      return Icons.mic_none_rounded;
    case SessionCartItemSource.labelScan:
      return Icons.document_scanner_outlined;
  }
}

(Color, Color) _toneForSource(
  SessionCartItemSource source,
  AppThemeTokens tokens,
) {
  switch (source) {
    case SessionCartItemSource.manual:
      return (tokens.surfaceSecondary, tokens.textSecondary);
    case SessionCartItemSource.voice:
      return (const Color(0xFFE9F0FF), const Color(0xFF4A66A6));
    case SessionCartItemSource.labelScan:
      return (tokens.accentSoft, const Color(0xFF5F950D));
  }
}
