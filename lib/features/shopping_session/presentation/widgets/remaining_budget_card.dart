import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class RemainingBudgetCard extends StatelessWidget {
  const RemainingBudgetCard({
    super.key,
    required this.remainingText,
    required this.spentText,
    required this.totalText,
    required this.progress,
    this.isNegativeRemaining = false,
  });

  final String remainingText;
  final String spentText;
  final String totalText;
  final double progress;
  final bool isNegativeRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final accentColor = isNegativeRemaining
        ? tokens.warningStrong
        : const Color(0xFF69A80D);

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
          center: const Alignment(0.86, -0.06),
          radius: 1.08,
          colors: [
            (isNegativeRemaining ? tokens.warningSoft : tokens.accentSoft)
                .withValues(alpha: 0.96),
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
                      'REMAINING BUDGET',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: remainingText,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: isNegativeRemaining
                                  ? tokens.warningStrong
                                  : tokens.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / $totalText',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: tokens.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                  Icons.shopping_cart_checkout_rounded,
                  color: accentColor,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Budget Usage',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(clampedProgress * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final progressWidth = constraints.maxWidth * clampedProgress;

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
                        gradient: LinearGradient(
                          colors: isNegativeRemaining
                              ? const [Color(0xFFF46B66), Color(0xFFFFA19C)]
                              : const [Color(0xFF98EA1B), Color(0xFFC9F96E)],
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
                            color: isNegativeRemaining
                                ? const Color(0xFFFFC9C6)
                                : const Color(0xFFDDFB8C),
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
                  label: 'SPENT',
                  value: spentText,
                  valueColor: tokens.textPrimary,
                ),
              ),
              Expanded(
                child: _BudgetMetricValue(
                  label: isNegativeRemaining ? 'OVER' : 'LEFT',
                  value: remainingText,
                  valueColor: isNegativeRemaining
                      ? tokens.warningStrong
                      : tokens.textPrimary,
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
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

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
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
