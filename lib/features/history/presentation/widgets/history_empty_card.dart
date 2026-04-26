import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HistoryEmptyCard extends StatelessWidget {
  const HistoryEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              size: 30,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Finished budgets and archived sessions will show up here once you start tracking more activity.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
