import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/dashboard/domain/entities/entities.dart';
import 'package:SaktoSpend/features/dashboard/presentation/widgets/dashboard_avoidable_spend_card.dart';
import 'package:SaktoSpend/features/dashboard/presentation/widgets/dashboard_recent_sessions_section.dart';
import 'package:SaktoSpend/features/dashboard/presentation/widgets/dashboard_spending_insights_card.dart';
import 'package:SaktoSpend/features/dashboard/presentation/widgets/dashboard_total_spent_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'dashboard_screen_logic.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, this.onOpenRecentBudget});

  final ValueChanged<String>? onOpenRecentBudget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final overviewAsync = ref.watch(_dashboardViewDataProvider);

    return overviewAsync.when(
      loading: () =>
          const SafeArea(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load overview: $error'),
          ),
        ),
      ),
      data: (viewData) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 42,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        viewData.monthLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF20242C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.shadowColor,
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFFFD658),
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              DashboardTotalSpentCard(
                amountLabel: MoneyUtils.centavosToCurrency(
                  viewData.totalSpentThisMonth,
                ),
                budgetAmountLabel: viewData.currentMonthBudgetTotal <= 0
                    ? 'No target'
                    : MoneyUtils.centavosToCurrency(
                        viewData.currentMonthBudgetTotal,
                      ),
                progress: viewData.spendingProgress,
                progressPercentLabel: viewData.spendingPercentLabel,
              ),
              const SizedBox(height: 20),
              DashboardAvoidableSpendCard(
                amountLabel: MoneyUtils.centavosToCurrency(
                  viewData.avoidableSpendThisMonth,
                ),
                entries: viewData.avoidableCategories
                    .map(
                      (entry) => DashboardAvoidableSpendEntryView(
                        label: entry.label,
                        amountLabel: entry.amountLabel,
                        icon: entry.icon,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              DashboardSpendingInsightsCard(
                title: 'View Deep Insights',
                subtitle: 'Analyze spending patterns',
              ),
              const SizedBox(height: 34),
              DashboardRecentSessionsSection(
                sessions: viewData.recentSessions
                    .map(
                      (session) => DashboardRecentSessionView(
                        budgetId: session.budgetId,
                        icon: session.icon,
                        iconColor: session.iconColor,
                        title: session.title,
                        typeLabel: session.typeLabel,
                        statusLabel: session.statusLabel,
                        statusColor: session.statusColor,
                        amountLabel: session.amountLabel,
                        budgetAmountLabel: session.budgetAmountLabel,
                        amountColor: session.amountColor,
                      ),
                    )
                    .toList(),
                onBudgetTap: onOpenRecentBudget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
