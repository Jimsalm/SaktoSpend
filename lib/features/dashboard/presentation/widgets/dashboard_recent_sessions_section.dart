import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardRecentSessionView {
  const DashboardRecentSessionView({
    required this.budgetId,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.typeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.amountLabel,
    required this.budgetAmountLabel,
    required this.amountColor,
  });

  final String budgetId;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String typeLabel;
  final String statusLabel;
  final Color statusColor;
  final String amountLabel;
  final String budgetAmountLabel;
  final Color amountColor;
}

class DashboardRecentSessionsSection extends StatelessWidget {
  const DashboardRecentSessionsSection({
    super.key,
    required this.sessions,
    this.onBudgetTap,
  });

  final List<DashboardRecentSessionView> sessions;
  final ValueChanged<String>? onBudgetTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Budgets',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                color: tokens.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'View All',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF6BAA0C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
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
            child: Text(
              'No budgets yet for this month.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          )
        else
          ...sessions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SessionTile(
                item: item,
                onTap: onBudgetTap == null
                    ? null
                    : () => onBudgetTap?.call(item.budgetId),
              ),
            ),
          ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.item, this.onTap});

  final DashboardRecentSessionView item;
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
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 30, color: item.iconColor),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.typeLabel} / ${item.statusLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amountLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      color: item.amountColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.budgetAmountLabel,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: item.amountColor.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
