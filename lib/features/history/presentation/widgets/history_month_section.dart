import 'package:flutter/material.dart';

class HistoryMonthItem {
  const HistoryMonthItem({
    required this.icon,
    required this.title,
    required this.meta,
    required this.amountLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String meta;
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

    return Column(
      children: [
        Row(
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              totalLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF8B867E),
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEEA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      item.meta,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF4D4942),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amountLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PROCESSED',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.6,
                      color: const Color(0xFF5A5751),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
