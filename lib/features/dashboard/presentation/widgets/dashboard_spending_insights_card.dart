import 'package:flutter/material.dart';

class DashboardSpendingInsightsCard extends StatelessWidget {
  const DashboardSpendingInsightsCard({
    super.key,
    required this.progress,
    required this.primaryLabel,
    required this.primaryValueLabel,
    required this.secondaryLabel,
    required this.secondaryValueLabel,
    required this.summaryText,
  });

  final double progress;
  final String primaryLabel;
  final String primaryValueLabel;
  final String secondaryLabel;
  final String secondaryValueLabel;
  final String summaryText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            _TargetRing(progress: progress),
            const SizedBox(height: 22),
            _InsightRow(
              dotColor: const Color(0xFF0F0F0F),
              label: primaryLabel,
              value: primaryValueLabel,
            ),
            const SizedBox(height: 12),
            _InsightRow(
              dotColor: const Color(0xFFD1CEC8),
              label: secondaryLabel,
              value: secondaryValueLabel,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text(
              summaryText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF46423B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetRing extends StatelessWidget {
  const _TargetRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 156,
      height: 156,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 156,
            height: 156,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF111111)),
              backgroundColor: const Color(0xFFD8D5CF),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress.clamp(0.0, 1.0) * 100).toInt()}%',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 32),
              ),
              Text(
                'TARGET',
                style: theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
