part of 'history_budget_detail_screen.dart';

final _historyBudgetItemsProvider =
    FutureProvider.family<List<SessionCartItem>, String>((ref, budgetId) async {
      return ref.watch(getSessionCartItemsUseCaseProvider).call(budgetId);
    });

String _budgetToken(String budgetId) {
  if (budgetId.length <= 6) {
    return budgetId;
  }
  return budgetId.substring(budgetId.length - 6);
}

int _totalSpentForHistoryBudget({
  required List<SessionCartItem> items,
  required int fallbackAmountCentavos,
}) {
  if (items.isEmpty) {
    return fallbackAmountCentavos;
  }
  return items.fold<int>(0, (sum, item) => sum + item.totalPrice);
}

Future<String> _repeatHistoryBudget({
  required WidgetRef ref,
  required HistoryItem historyItem,
}) async {
  final now = DateTime.now();
  final newBudget = Budget(
    id: 'budget_${now.microsecondsSinceEpoch}',
    name: historyItem.name,
    type: _parseBudgetType(historyItem.type),
    amount: historyItem.amountCentavos,
    warningPercent: historyItem.warningPercent,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  final existingItems = await ref
      .read(getSessionCartItemsUseCaseProvider)
      .call(historyItem.budgetId);

  await ref.read(createBudgetUseCaseProvider).call(newBudget);

  if (existingItems.isNotEmpty) {
    await ref
        .read(replaceSessionCartItemsUseCaseProvider)
        .call(budgetId: newBudget.id, items: existingItems);
  }

  ref.invalidate(budgetListProvider);
  ref.invalidate(sessionCartTotalsProvider);
  ref.invalidate(historyOverviewProvider);

  return '${_monthName(now.month)} ${now.year}';
}

BudgetType _parseBudgetType(String type) {
  switch (type.toLowerCase()) {
    case 'weekly':
      return BudgetType.weekly;
    case 'monthly':
      return BudgetType.monthly;
    case 'shopping':
    default:
      return BudgetType.shopping;
  }
}

String _dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '${_monthName(date.month)} $day, ${date.year}';
}

String _monthName(int month) {
  const monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  if (month < 1 || month > 12) {
    return 'Unknown';
  }
  return monthNames[month - 1];
}
