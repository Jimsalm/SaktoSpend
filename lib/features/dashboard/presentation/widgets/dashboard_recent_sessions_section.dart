import 'package:flutter/material.dart';

class DashboardRecentSessionView {
  const DashboardRecentSessionView({
    required this.budgetId,
    required this.icon,
    required this.title,
    required this.meta,
    required this.amountLabel,
  });

  final String budgetId;
  final IconData icon;
  final String title;
  final String meta;
  final String amountLabel;
}

class DashboardRecentSessionsSection extends StatelessWidget {
  const DashboardRecentSessionsSection({
    super.key,
    required this.sessions,
    this.onBudgetTap,
  });

  final List<DashboardRecentSessionView> sessions;
  final ValueChanged<String>? onBudgetTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent Budgets', style: theme.textTheme.titleLarge),
            const Spacer(),
            const Icon(Icons.tune, size: 20),
          ],
        ),
        const SizedBox(height: 14),
        if (sessions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'No budgets yet for this month.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF68645C),
                ),
              ),
            ),
          )
        else
          ...sessions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SessionTile(
                item: item,
                onTap: onBudgetTap == null
                    ? null
                    : () => onBudgetTap?.call(item.budgetId),
              ),
            ),
          ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.item, this.onTap});

  final DashboardRecentSessionView item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      item.meta,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.amountLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
