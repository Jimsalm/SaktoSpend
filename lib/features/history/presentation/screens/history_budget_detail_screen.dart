import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/history/domain/entities/history_item.dart';
import 'package:SaktoSpend/features/history/presentation/widgets/history_budget_detail_row.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'history_budget_detail_screen_logic.dart';

class HistoryBudgetDetailScreen extends ConsumerStatefulWidget {
  const HistoryBudgetDetailScreen({super.key, required this.historyItem});

  final HistoryItem historyItem;

  @override
  ConsumerState<HistoryBudgetDetailScreen> createState() =>
      _HistoryBudgetDetailScreenState();
}

class _HistoryBudgetDetailScreenState
    extends ConsumerState<HistoryBudgetDetailScreen> {
  bool _isRepeating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetToken = _budgetToken(widget.historyItem.budgetId);
    final itemsAsync = ref.watch(
      _historyBudgetItemsProvider(widget.historyItem.budgetId),
    );

    final items = itemsAsync.valueOrNull ?? const <SessionCartItem>[];
    final totalSpent = _totalSpentForHistoryBudget(
      items: items,
      fallbackAmountCentavos: widget.historyItem.amountCentavos,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Budget Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'BUDGET #$budgetToken',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.6,
                      color: const Color(0xFF8A867F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL SPENT',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          letterSpacing: 1.6,
                          color: const Color(0xFF8A867F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        MoneyUtils.centavosToCurrency(totalSpent),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.historyItem.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 48,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _dateLabel(widget.historyItem.createdAt),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF7B766E),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E2DD)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEBE8E3)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              'PRODUCT DESCRIPTION',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'QTY',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'UNIT',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'TOTAL',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (itemsAsync.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )
                    else if (itemsAsync.hasError)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Failed to load items: ${itemsAsync.error}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    else if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No recorded items for this budget.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6D685F),
                          ),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => HistoryBudgetDetailRow(item: item),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: SizedBox(
          height: 54,
          child: TextButton(
            onPressed: _isRepeating ? null : _repeatBudget,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF111111),
              disabledBackgroundColor: const Color(0xFF4A4A4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _isRepeating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'REPEAT THIS BUDGET',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _repeatBudget() async {
    setState(() => _isRepeating = true);

    try {
      final createdForLabel = await _repeatHistoryBudget(
        ref: ref,
        historyItem: widget.historyItem,
      );

      if (!mounted) {
        return;
      }
      AppSnackbars.showSuccess(
        context,
        'Created "${widget.historyItem.name}" for $createdForLabel',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackbars.showError(context, 'Failed to repeat budget: $error');
    } finally {
      if (mounted) {
        setState(() => _isRepeating = false);
      }
    }
  }
}
