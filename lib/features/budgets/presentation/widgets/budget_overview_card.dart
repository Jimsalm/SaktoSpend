import 'package:flutter/material.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    super.key,
    required this.remainingAmountText,
    required this.utilization,
    required this.statusLabel,
  });

  final String remainingAmountText;
  final double utilization;
  final String statusLabel;

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
              remainingAmountText,
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
                  child: _BudgetMetricValue(
                    label: 'STATUS',
                    value: statusLabel,
                    dot: true,
                  ),
                ),
                Expanded(
                  child: _BudgetMetricValue(
                    label: 'UTILIZATION',
                    value: '${(utilization * 100).toStringAsFixed(1)}%',
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

class _BudgetMetricValue extends StatelessWidget {
  const _BudgetMetricValue({
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
