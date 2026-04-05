import 'package:flutter/material.dart';

class BudgetsTabScreen extends StatelessWidget {
  const BudgetsTabScreen({
    super.key,
    required this.onOpenActiveSession,
  });

  final VoidCallback onOpenActiveSession;

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
                  'Budgets',
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
            const SizedBox(height: 26),
            Text(
              'Managing 3 active allocations for November 2023.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF4D4942),
              ),
            ),
            const SizedBox(height: 22),
            const _OverviewCard(),
            const SizedBox(height: 14),
            const _PastPerformanceCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'ACTIVE BUDGETS',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.filter_list, size: 18),
                const SizedBox(width: 14),
                const Icon(Icons.tune, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            ..._sampleBudgets.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BudgetItemCard(
                    item: item,
                    onTap: index == 0 ? onOpenActiveSession : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFE8E5DF),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                'TOTAL OVERVIEW',
                style: theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '\$4,250.00',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 56),
            ),
            const SizedBox(height: 4),
            Text(
              'Remaining across all active budgets',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF4E4A43),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: _LabelValue(
                    label: 'STATUS',
                    value: 'Healthy',
                    dot: true,
                  ),
                ),
                Expanded(
                  child: _LabelValue(
                    label: 'UTILIZATION',
                    value: '42.5%',
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

class _PastPerformanceCard extends StatelessWidget {
  const _PastPerformanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_outlined, size: 22),
            const SizedBox(height: 14),
            Text('Past Performance', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'You stayed 12% under budget last month.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF4E4A43),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'VIEW REPORT',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({
    required this.label,
    required this.value,
    this.dot = false,
  });

  final String label;
  final String value;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (dot) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _BudgetItemCard extends StatelessWidget {
  const _BudgetItemCard({
    required this.item,
    this.onTap,
  });

  final _BudgetTileItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEEA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          '${item.spent} of ${item.total}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF36322C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.badgeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: item.progress > 1 ? 1 : item.progress,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF111111)),
                  backgroundColor: const Color(0xFFE2DFD9),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    item.usedText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF3C3832),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.leftText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: item.leftWarning ? const Color(0xFFBB1414) : const Color(0xFF3C3832),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Spacer(),
                  Icon(Icons.more_vert, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetTileItem {
  const _BudgetTileItem({
    required this.icon,
    required this.name,
    required this.spent,
    required this.total,
    required this.status,
    required this.badgeBg,
    required this.badgeColor,
    required this.progress,
    required this.usedText,
    required this.leftText,
    this.leftWarning = false,
  });

  final IconData icon;
  final String name;
  final String spent;
  final String total;
  final String status;
  final Color badgeBg;
  final Color badgeColor;
  final double progress;
  final String usedText;
  final String leftText;
  final bool leftWarning;
}

const _sampleBudgets = <_BudgetTileItem>[
  _BudgetTileItem(
    icon: Icons.shopping_basket_outlined,
    name: 'Groceries',
    spent: '\$450.00',
    total: '\$800.00',
    status: 'Safe',
    badgeBg: Color(0xFFE9E7E2),
    badgeColor: Color(0xFF1B1B1B),
    progress: 0.56,
    usedText: '56% used',
    leftText: '\$350.00 left',
  ),
  _BudgetTileItem(
    icon: Icons.restaurant_outlined,
    name: 'Dining Out',
    spent: '\$280.00',
    total: '\$300.00',
    status: 'Warning',
    badgeBg: Color(0xFFFBE3E0),
    badgeColor: Color(0xFFB81A16),
    progress: 0.93,
    usedText: '93% used',
    leftText: '\$20.00 left',
    leftWarning: true,
  ),
  _BudgetTileItem(
    icon: Icons.flight_takeoff_outlined,
    name: 'Tokyo Travel',
    spent: '\$3,200.00',
    total: '\$3,000.00',
    status: 'Exceeded',
    badgeBg: Color(0xFF111111),
    badgeColor: Colors.white,
    progress: 1.06,
    usedText: '106% used',
    leftText: '-\$200.00',
  ),
];
