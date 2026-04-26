import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardTotalSpentCard extends StatelessWidget {
  const DashboardTotalSpentCard({
    super.key,
    required this.amountLabel,
    required this.budgetAmountLabel,
    required this.progress,
    required this.progressPercentLabel,
  });

  final String amountLabel;
  final String budgetAmountLabel;
  final double progress;
  final int progressPercentLabel;

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
          center: const Alignment(0.85, -0.05),
          radius: 1.05,
          colors: [
            tokens.accentSoft.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.96),
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
                      'TOTAL SPENT THIS MONTH',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.8,
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: amountLabel,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / $budgetAmountLabel',
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
                  Icons.account_balance_rounded,
                  color: const Color(0xFF69A80D),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
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
                '$progressPercentLabel%',
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
              final clampedProgress = progress.clamp(0.0, 1.0);
              final progressWidth = constraints.maxWidth * clampedProgress;

              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(
                      height: 14,
                      color: const Color(0xFFD9E0EB),
                    ),
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
        ],
      ),
    );
  }
}
