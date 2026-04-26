part of 'active_session_screen.dart';

Future<void> _openVoiceEntrySheet(
  BuildContext context, {
  required int budgetTotal,
  required int currentSessionTotal,
  required bool hardBudgetModeEnabled,
  required ValueChanged<SessionCartItem> onAddManualItem,
}) async {
  final voiceDraft = await showVoiceCaptureSheet(context);
  if (voiceDraft == null || !context.mounted) {
    return;
  }

  final created = await showCartEntrySheet(
    context,
    initialItem: SessionCartItem(
      name: voiceDraft.name,
      category: 'Groceries',
      unitPrice: voiceDraft.unitPrice,
      quantity: 1,
      unit: 'PC',
      isEssential: false,
      source: SessionCartItemSource.voice,
    ),
    budgetTotal: budgetTotal,
    budgetRemainingBeforeEntry: budgetTotal - currentSessionTotal,
    submitLabel: 'Confirm Entry',
    hardBudgetModeEnabled: hardBudgetModeEnabled,
  );

  await _dispatchAddedItem(created, onAddManualItem: onAddManualItem);
}

Future<void> _openManualEntrySheet(
  BuildContext context, {
  required int budgetTotal,
  required int currentSessionTotal,
  required bool hardBudgetModeEnabled,
  required ValueChanged<SessionCartItem> onAddManualItem,
}) async {
  final created = await showCartEntrySheet(
    context,
    initialItem: const SessionCartItem(
      name: '',
      category: 'Groceries',
      unitPrice: 0,
      quantity: 1,
      unit: 'PC',
      isEssential: false,
      source: SessionCartItemSource.manual,
    ),
    budgetTotal: budgetTotal,
    budgetRemainingBeforeEntry: budgetTotal - currentSessionTotal,
    submitLabel: 'Confirm Entry',
    hardBudgetModeEnabled: hardBudgetModeEnabled,
  );

  await _dispatchAddedItem(created, onAddManualItem: onAddManualItem);
}

Future<void> _openEditEntrySheet(
  BuildContext context, {
  required int index,
  required SessionCartItem item,
  required int budgetTotal,
  required int currentSessionTotal,
  required bool hardBudgetModeEnabled,
  required void Function(int index, SessionCartItem item) onEditItem,
}) async {
  final updated = await showCartEntrySheet(
    context,
    initialItem: item,
    budgetTotal: budgetTotal,
    budgetRemainingBeforeEntry:
        budgetTotal - (currentSessionTotal - item.totalPrice),
    submitLabel: 'Save Changes',
    hardBudgetModeEnabled: hardBudgetModeEnabled,
  );
  if (updated == null) {
    return;
  }

  await Future<void>.delayed(const Duration(milliseconds: 240));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    onEditItem(index, updated);
  });
}

Future<void> _dispatchAddedItem(
  SessionCartItem? item, {
  required ValueChanged<SessionCartItem> onAddManualItem,
}) async {
  if (item == null) {
    return;
  }
  await Future<void>.delayed(const Duration(milliseconds: 240));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    onAddManualItem(item);
  });
}

String _money(int value) => MoneyUtils.centavosToCurrency(value);
