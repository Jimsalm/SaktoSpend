import 'package:flutter/material.dart';

class DashboardTotalSpentCard extends StatelessWidget {
  const DashboardTotalSpentCard({
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL SPENT THIS MONTH',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: const Color(0xFF666259),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amountLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 46,
                    color: const Color(0xFF12110F),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF12110F),
          ),
        ],
      ),
    );
  }
}
