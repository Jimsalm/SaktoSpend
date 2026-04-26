import 'package:SaktoSpend/core/theme/app_theme.dart';
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
    final tokens = context.appThemeTokens;
    final clampedUtilization = utilization.clamp(0.0, 1.0);
    final statusColor = switch (statusLabel.toLowerCase()) {
      'exceeded' => tokens.warningStrong,
      'warning' => const Color(0xFFD77A00),
      'safe' => const Color(0xFF69A80D),
      _ => tokens.textSecondary,
    };

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
          center: const Alignment(0.84, -0.06),
          radius: 1.08,
          colors: [
            tokens.accentSoft.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.97),
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL OVERVIEW',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.8,
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      remainingAmountText,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 38,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Remaining across all active budgets',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
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
                  Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF69A80D),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Budget Utilization',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(clampedUtilization * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF69A80D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final progressWidth = constraints.maxWidth * clampedUtilization;

              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(height: 14, color: const Color(0xFFD9E0EB)),
                    Container(
                      width: progressWidth,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF98EA1B), Color(0xFFC9F96E)],
                        ),
                      ),
                    ),
                    if (progressWidth > 20)
                      Positioned(
                        left: progressWidth - 20,
                        top: 1,
                        child: Container(
                          width: 20,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDFB8C),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BudgetMetricValue(
                  label: 'STATUS',
                  value: statusLabel,
                  dotColor: statusColor,
                ),
              ),
              Expanded(
                child: _BudgetMetricValue(
                  label: 'UTILIZATION',
                  value: '${(clampedUtilization * 100).toStringAsFixed(1)}%',
                  valueColor: tokens.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetMetricValue extends StatelessWidget {
  const _BudgetMetricValue({
    required this.label,
    required this.value,
    this.dotColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? dotColor;
  final Color? valueColor;

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
            letterSpacing: 1.6,
            color: tokens.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: valueColor ?? tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
