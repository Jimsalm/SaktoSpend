import 'package:budget_tracker/core/utils/utils.dart';
import 'package:budget_tracker/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:flutter/material.dart';

Future<SessionCartItem?> showCartEntrySheet(
  BuildContext context, {
  required SessionCartItem initialItem,
  required int budgetTotal,
  required int budgetRemainingBeforeEntry,
  required String submitLabel,
}) async {
  var name = initialItem.name;
  var priceText = MoneyUtils.centavosToInputValue(initialItem.unitPrice);
  var category = initialItem.category;
  var quantity = initialItem.quantity;
  var unit = initialItem.unit;
  var isEssential = initialItem.isEssential;

  final categories = <String>{
    'Groceries',
    'Beverage',
    'Pantry & Grains',
    'Dairy',
    'Lifestyle',
    category,
  }.toList();

  final result = await showModalBottomSheet<SessionCartItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF8F7F4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final total = _parseEntryPrice(priceText) * quantity;
          final remaining = budgetRemainingBeforeEntry - total;
          final safeBudgetBase = budgetTotal > 0
              ? budgetTotal
              : (budgetRemainingBeforeEntry > 0
                    ? budgetRemainingBeforeEntry
                    : 0);
          final progress = safeBudgetBase <= 0
              ? 0.0
              : (remaining / safeBudgetBase).clamp(0.0, 1.0);
          final viewInsets = MediaQuery.of(context).viewInsets.bottom;

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + viewInsets),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Entry Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 30,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          await Future<void>.delayed(
                            const Duration(milliseconds: 10),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    'MANUAL DRAFT',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF75726C),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _editorLabel(theme, 'PRODUCT IDENTITY'),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: name,
                    onChanged: (value) => setModalState(() => name = value),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Organic Almond Milk',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _editorLabel(theme, 'CATEGORY'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: category,
                              isExpanded: true,
                              items: categories
                                  .map(
                                    (entry) => DropdownMenuItem<String>(
                                      value: entry,
                                      child: Text(
                                        entry,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              selectedItemBuilder: (context) => categories
                                  .map(
                                    (entry) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setModalState(() => category = value);
                              },
                              decoration: const InputDecoration(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _editorLabel(theme, 'UNIT PRICE'),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: priceText,
                              onChanged: (value) {
                                setModalState(() => priceText = value);
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                prefixText: '₱  ',
                                hintText: '0.00',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _editorLabel(theme, 'QUANTITY'),
                            const SizedBox(height: 6),
                            _editorInputLike(
                              child: Row(
                                children: [
                                  _editorTapLabel('-', () {
                                    setModalState(
                                      () => quantity = (quantity - 1)
                                          .clamp(1, 999)
                                          .toInt(),
                                    );
                                  }, theme),
                                  const Spacer(),
                                  Text(
                                    '$quantity',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 26),
                                  ),
                                  const Spacer(),
                                  _editorTapLabel('+', () {
                                    setModalState(
                                      () => quantity = (quantity + 1)
                                          .clamp(1, 999)
                                          .toInt(),
                                    );
                                  }, theme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _editorLabel(theme, 'UNIT'),
                            const SizedBox(height: 6),
                            _editorInputLike(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _editorSegButton(
                                      'PC',
                                      unit == 'PC',
                                      theme,
                                      () => setModalState(() => unit = 'PC'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _editorSegButton(
                                      'KG',
                                      unit == 'KG',
                                      theme,
                                      () => setModalState(() => unit = 'KG'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _editorInputLike(
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'ESSENTIAL ITEM',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isEssential,
                          onChanged: (value) =>
                              setModalState(() => isEssential = value),
                          activeTrackColor: Colors.black,
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'BUDGET IMPACT',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% Left',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            value: progress,
                            backgroundColor: const Color(0xFF454545),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Remaining: ${remaining < 0 ? '-' : ''}${_money(remaining.abs())}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFD7D7D7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _editorLabel(theme, 'TOTAL COST'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        _money(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 44,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () async {
                        final rawName = name.trim();
                        final nameValue = rawName.isEmpty
                            ? 'Manual Item'
                            : rawName;
                        final price = _parseEntryPrice(priceText);
                        if (price < 0) {
                          return;
                        }
                        FocusManager.instance.primaryFocus?.unfocus();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 10),
                        );
                        if (context.mounted) {
                          Navigator.pop(
                            context,
                            initialItem.copyWith(
                              name: nameValue,
                              category: category,
                              unitPrice: price,
                              quantity: quantity,
                              unit: unit,
                              isEssential: isEssential,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        submitLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  return result;
}

int _parseEntryPrice(String raw) {
  return MoneyUtils.parseCurrencyToCentavos(raw);
}

Widget _editorLabel(ThemeData theme, String text) {
  return Text(
    text,
    style: theme.textTheme.bodyMedium?.copyWith(
      letterSpacing: 1.7,
      fontWeight: FontWeight.w700,
    ),
  );
}

Widget _editorInputLike({required Widget child}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFEAE7E2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

Widget _editorTapLabel(String text, VoidCallback onTap, ThemeData theme) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(fontSize: 26),
      ),
    ),
  );
}

Widget _editorSegButton(
  String label,
  bool selected,
  ThemeData theme,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(5),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.black : const Color(0xFFE9E6E1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : const Color(0xFF141414),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

String _money(int value) => MoneyUtils.centavosToCurrency(value);
