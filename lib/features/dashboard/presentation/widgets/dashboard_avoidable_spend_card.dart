import 'package:flutter/material.dart';

class DashboardAvoidableSpendCard extends StatelessWidget {
  const DashboardAvoidableSpendCard({
    super.key,
    required this.amountLabel,
  });

  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E1D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVOIDABLE SPEND',
            style: theme.textTheme.bodyMedium?.copyWith(
              letterSpacing: 1.8,
              color: const Color(0xFF666259),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 46,
                  color: const Color(0xFF12110F),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'THIS MONTH',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF666259),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Spent on non-essential items',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4F4B44),
            ),
          ),
        ],
      ),
    );
  }
}
