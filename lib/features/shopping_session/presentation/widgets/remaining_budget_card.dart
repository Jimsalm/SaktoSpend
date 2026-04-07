import 'package:flutter/material.dart';

class RemainingBudgetCard extends StatelessWidget {
  const RemainingBudgetCard({
    super.key,
    required this.remainingText,
    required this.spentText,
    required this.totalText,
    required this.progress,
  });

  final String remainingText;
  final String spentText;
  final String totalText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'REMAINING BUDGET',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFC7C7C7),
              letterSpacing: 1.7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            remainingText,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF5F5F5)),
              backgroundColor: const Color(0xFF262626),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Spent $spentText of $totalText',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFA2A2A2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
