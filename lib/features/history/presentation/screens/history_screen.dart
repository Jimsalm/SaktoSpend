import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'History',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 52,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEBE6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 34, color: Color(0xFF5A5751)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search sessions, stores, or items...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF8D8880),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _MonthSection(
              monthLabel: 'MARCH 2024',
              totalLabel: '\$1,240.50 Total',
              items: _marchItems,
            ),
            const SizedBox(height: 18),
            const _MonthSection(
              monthLabel: 'FEBRUARY 2024',
              totalLabel: '\$850.15 Total',
              items: _febItems,
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    title: 'LONGEST STREAK',
                    value: '14',
                    valueSuffix: 'DAYS',
                    dark: false,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    title: 'BUDGET GOAL',
                    value: '92%',
                    dark: true,
                    progress: 0.92,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.monthLabel,
    required this.totalLabel,
    required this.items,
  });

  final String monthLabel;
  final String totalLabel;
  final List<_HistoryItem> items;

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

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                  Text(item.store, style: theme.textTheme.titleLarge),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    this.valueSuffix,
    required this.dark,
    this.progress,
  });

  final String title;
  final String value;
  final String? valueSuffix;
  final bool dark;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = dark ? Colors.black : const Color(0xFFF0EEEA);
    final primaryColor = dark ? Colors.white : const Color(0xFF151515);
    final secondaryColor = dark ? const Color(0xFF868686) : const Color(0xFF56524A);

    return Container(
      height: 182,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              letterSpacing: 2.4,
              color: secondaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: primaryColor,
                  fontSize: 58,
                ),
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    valueSuffix!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: secondaryColor),
                  ),
                ),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progress,
                valueColor: AlwaysStoppedAnimation(
                  dark ? const Color(0xFFF2F2F2) : const Color(0xFF121212),
                ),
                backgroundColor: dark ? const Color(0xFF363636) : const Color(0xFFD9D6CF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.icon,
    required this.store,
    required this.meta,
    required this.amount,
  });

  final IconData icon;
  final String store;
  final String meta;
  final String amount;
}

const _marchItems = <_HistoryItem>[
  _HistoryItem(
    icon: Icons.shopping_bag_outlined,
    store: 'Whole Foods Market',
    meta: 'March 14, 2024 • 12 items',
    amount: '\$142.20',
  ),
  _HistoryItem(
    icon: Icons.shopping_bag_outlined,
    store: 'Apple Store',
    meta: 'March 10, 2024 • 2 items',
    amount: '\$949.00',
  ),
  _HistoryItem(
    icon: Icons.storefront_outlined,
    store: 'Blue Bottle Coffee',
    meta: 'March 02, 2024 • 3 items',
    amount: '\$24.50',
  ),
];

const _febItems = <_HistoryItem>[
  _HistoryItem(
    icon: Icons.shopping_basket_outlined,
    store: "Trader Joe's",
    meta: 'February 28, 2024 • 18 items',
    amount: '\$210.80',
  ),
  _HistoryItem(
    icon: Icons.checkroom_outlined,
    store: 'Everlane',
    meta: 'February 14, 2024 • 1 item',
    amount: '\$88.00',
  ),
];
