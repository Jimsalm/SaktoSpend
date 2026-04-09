import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/history/domain/entities/history_item.dart'
    as history_domain;
import 'package:SaktoSpend/features/history/domain/entities/history_overview.dart';
import 'package:SaktoSpend/features/history/presentation/screens/history_budget_detail_screen.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_empty_card.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_month_section.dart';
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
    final historyAsync = ref.watch(_historyViewDataProvider);

    return historyAsync.when(
      loading: () =>
          const SafeArea(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load history: $error'),
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
                  Text(
                    'History',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 52,
                    ),
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
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBE6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 30,
                      color: Color(0xFF5A5751),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Search previous budgets...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF8D8880),
                          ),
                          suffixIcon: _searchQuery.trim().isEmpty
                              ? null
                              : IconButton(
                                  splashRadius: 18,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF5A5751),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (viewData.sections.isEmpty) ...[
                const HistoryEmptyCard(),
              ] else ...[
                ...() {
                  final filteredViewData = viewData.filterByQuery(_searchQuery);
                  if (filteredViewData.sections.isEmpty) {
                    return const <Widget>[HistorySearchEmptyCard()];
                  }

                  return filteredViewData.sections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: HistoryMonthSection(
                        monthLabel: section.monthLabel,
                        totalLabel:
                            '${MoneyUtils.centavosToCurrency(section.totalCentavos)} Total',
                        items: section.items
                            .map(
                              (item) => HistoryMonthItem(
                                icon: item.icon,
                                title: item.title,
                                meta: item.meta,
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
                  }).toList();
                }(),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
