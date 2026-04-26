import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardSpendingInsightsCard extends StatelessWidget {
  const DashboardSpendingInsightsCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
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
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: const Color(0xFF6BAA0C),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: tokens.textSecondary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
