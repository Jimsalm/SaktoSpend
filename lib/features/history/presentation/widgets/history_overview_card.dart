import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HistoryOverviewCard extends StatelessWidget {
  const HistoryOverviewCard({
    super.key,
    required this.totalValueLabel,
    required this.budgetCount,
    required this.monthCount,
    required this.isFiltered,
  });

  final String totalValueLabel;
  final int budgetCount;
  final int monthCount;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(0.88, -0.06),
          radius: 1.08,
          colors: [
            tokens.accentSoft.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.97),
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFiltered ? 'FILTERED HISTORY' : 'BUDGET HISTORY',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  totalValueLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 36,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'Total budget value across the current search results.'
                      : 'Total budget value recorded in your saved history.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HistoryOverviewMetric(
                        label: 'BUDGETS',
                        value: '$budgetCount',
                      ),
                    ),
                    Expanded(
                      child: _HistoryOverviewMetric(
                        label: 'MONTHS',
                        value: '$monthCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              shape: BoxShape.circle,
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Icon(
              Icons.history_rounded,
              color: tokens.accentStrong,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryOverviewMetric extends StatelessWidget {
  const _HistoryOverviewMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: tokens.textSecondary,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
