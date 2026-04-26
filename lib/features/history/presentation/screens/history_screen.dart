import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/history/domain/entities/history_item.dart'
    as history_domain;
import 'package:SaktoSpend/features/history/domain/entities/history_overview.dart';
import 'package:SaktoSpend/features/history/presentation/screens/history_budget_detail_screen.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_empty_card.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_month_section.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_overview_card.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_search_empty_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'history_screen_logic.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final historyAsync = ref.watch(_historyViewDataProvider);

    return historyAsync.when(
      loading: () => SafeArea(
        child: Center(
          child: Container(
            width: 88,
            height: 88,
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
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: tokens.textPrimary,
              ),
            ),
          ),
        ),
      ),
      error: (error, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 26),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tokens.warningSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: tokens.warningStrong,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'History unavailable',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Failed to load history: $error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (viewData) => SafeArea(
        child: Builder(
          builder: (context) {
            final filteredViewData = viewData.filterByQuery(_searchQuery);
            final hasHistory = viewData.sections.isNotEmpty;
            final hasFilteredResults = filteredViewData.sections.isNotEmpty;
            final isSearching = _searchQuery.trim().isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
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
                              'History',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 40,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Review past budgets, search older entries, and reopen saved details when you need context.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: tokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF20242C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
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
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (hasHistory) ...[
                    HistoryOverviewCard(
                      totalValueLabel: MoneyUtils.centavosToCurrency(
                        filteredViewData.totalCentavos,
                      ),
                      budgetCount: filteredViewData.itemCount,
                      monthCount: filteredViewData.monthCount,
                      isFiltered: isSearching,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.surfacePrimary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tokens.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.shadowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: tokens.surfaceSecondary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: tokens.textPrimary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              hintText: 'Search previous budgets...',
                              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                color: tokens.textTertiary,
                              ),
                              suffixIcon: isSearching
                                  ? IconButton(
                                      splashRadius: 18,
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: tokens.textSecondary,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasHistory && isSearching && hasFilteredResults) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${filteredViewData.itemCount} matching budgets',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (!hasHistory) ...[
                    const HistoryEmptyCard(),
                  ] else if (!hasFilteredResults) ...[
                    const HistorySearchEmptyCard(),
                  ] else ...[
                    ...filteredViewData.sections.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: HistoryMonthSection(
                          monthLabel: section.monthLabel,
                          totalLabel:
                              '${MoneyUtils.centavosToCurrency(section.totalCentavos)} Total',
                          items: section.items
                              .map(
                                (item) => HistoryMonthItem(
                                  icon: item.icon,
                                  title: item.title,
                                  dateLabel: item.dateLabel,
                                  typeLabel: item.typeLabel,
                                  isActive: item.isActive,
                                  amountLabel: MoneyUtils.centavosToCurrency(
                                    item.amountCentavos,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => HistoryBudgetDetailScreen(
                                          historyItem: item.source,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
