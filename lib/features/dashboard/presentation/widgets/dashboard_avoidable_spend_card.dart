import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardAvoidableSpendEntryView {
  const DashboardAvoidableSpendEntryView({
    required this.label,
    required this.amountLabel,
    required this.icon,
  });

  final String label;
  final String amountLabel;
  final IconData icon;
}

class DashboardAvoidableSpendCard extends StatelessWidget {
  const DashboardAvoidableSpendCard({
    super.key,
    required this.amountLabel,
    required this.entries,
  });

  final String amountLabel;
  final List<DashboardAvoidableSpendEntryView> entries;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'AVOIDABLE SPEND',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.warning_rounded,
                color: tokens.warningStrong,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amountLabel,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 36,
              color: tokens.warningStrong,
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Text(
              'No non-essential spend recorded this month.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: tokens.textSecondary,
              ),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AvoidableEntryRow(entry: entry),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvoidableEntryRow extends StatelessWidget {
  const _AvoidableEntryRow({required this.entry});

  final DashboardAvoidableSpendEntryView entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: tokens.surfaceSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            entry.icon,
            size: 18,
            color: tokens.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            entry.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: tokens.textPrimary,
            ),
          ),
        ),
        Text(
          entry.amountLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: tokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
