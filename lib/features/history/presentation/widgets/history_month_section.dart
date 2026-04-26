import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HistoryMonthItem {
  const HistoryMonthItem({
    required this.icon,
    required this.title,
    required this.dateLabel,
    required this.typeLabel,
    required this.isActive,
    required this.amountLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String dateLabel;
  final String typeLabel;
  final bool isActive;
  final String amountLabel;
  final VoidCallback? onTap;
}

class HistoryMonthSection extends StatelessWidget {
  const HistoryMonthSection({
    super.key,
    required this.monthLabel,
    required this.totalLabel,
    required this.items,
  });

  final String monthLabel;
  final String totalLabel;
  final List<HistoryMonthItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
                color: tokens.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: tokens.surfacePrimary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: tokens.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: tokens.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                totalLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoryItemCard(item: item),
          ),
        ),
      ],
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({required this.item});

  final HistoryMonthItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: item.onTap,
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
                    item.icon,
                    size: 28,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.dateLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HistoryMetaChip(
                            icon: Icons.sell_outlined,
                            label: item.typeLabel,
                            backgroundColor: tokens.surfaceSecondary,
                            foregroundColor: tokens.textSecondary,
                          ),
                          _HistoryMetaChip(
                            icon: item.isActive
                                ? Icons.check_circle_outline_rounded
                                : Icons.pause_circle_outline_rounded,
                            label: item.isActive ? 'Active' : 'Inactive',
                            backgroundColor: item.isActive
                                ? tokens.accentSoft
                                : tokens.surfaceSecondary,
                            foregroundColor: item.isActive
                                ? const Color(0xFF5F950D)
                                : tokens.textSecondary,
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
                      item.amountLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
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

class _HistoryMetaChip extends StatelessWidget {
  const _HistoryMetaChip({
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
