import 'package:SaktoSpend/app/providers/providers.dart';
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
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewData.monthLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF646057),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overview',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 52,
                          height: 0.95,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DashboardTotalSpentCard(
                amountLabel: MoneyUtils.centavosToCurrency(
                  viewData.totalSpentThisMonth,
                ),
              ),
              const SizedBox(height: 12),
              DashboardAvoidableSpendCard(
                amountLabel: MoneyUtils.centavosToCurrency(
                  viewData.avoidableSpendThisMonth,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Text('Spending Insights', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              DashboardSpendingInsightsCard(
                progress: viewData.spendingProgress,
                primaryLabel: 'Essential Items',
                primaryValueLabel: MoneyUtils.centavosToCurrency(
                  viewData.essentialSpendThisMonth,
                ),
                secondaryLabel: 'Non-Essential',
                secondaryValueLabel: MoneyUtils.centavosToCurrency(
                  viewData.avoidableSpendThisMonth,
                ),
                summaryText: viewData.insightSummary,
              ),
              const SizedBox(height: 24),
              DashboardRecentSessionsSection(
                sessions: viewData.recentSessions
                    .map(
                      (session) => DashboardRecentSessionView(
                        budgetId: session.budgetId,
                        icon: session.icon,
                        title: session.title,
                        meta: session.meta,
                        amountLabel: session.amountLabel,
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
