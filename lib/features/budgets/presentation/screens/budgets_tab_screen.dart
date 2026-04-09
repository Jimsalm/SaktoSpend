import 'dart:math' as math;

import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/budgets/presentation/widgets/budget_allocation_card.dart';
import 'package:SaktoSpend/features/budgets/presentation/widgets/budget_overview_card.dart';
import 'package:SaktoSpend/features/budgets/presentation/widgets/empty_budgets_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'budgets_tab_logic.dart';

class BudgetsTabScreen extends ConsumerStatefulWidget {
  const BudgetsTabScreen({
    super.key,
    required this.onOpenActiveSession,
    required this.onCreateActionChanged,
  });

  final ValueChanged<Budget> onOpenActiveSession;
  final ValueChanged<VoidCallback?> onCreateActionChanged;

  @override
  ConsumerState<BudgetsTabScreen> createState() => _BudgetsTabScreenState();
}

class _BudgetsTabScreenState extends ConsumerState<BudgetsTabScreen> {
  @override
  void initState() {
    super.initState();
    widget.onCreateActionChanged(_openCreateDialog);
  }

  @override
  void didUpdateWidget(covariant BudgetsTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onCreateActionChanged != widget.onCreateActionChanged) {
      widget.onCreateActionChanged(_openCreateDialog);
    }
  }

  @override
  void dispose() {
    widget.onCreateActionChanged(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetListProvider);
    final sessionTotalsAsync = ref.watch(sessionCartTotalsProvider);

    if (budgetsAsync.isLoading || sessionTotalsAsync.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    if (budgetsAsync.hasError) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load budgets: ${budgetsAsync.error}'),
          ),
        ),
      );
    }

    if (sessionTotalsAsync.hasError) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load budget totals: ${sessionTotalsAsync.error}',
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: _buildContent(
        context,
        budgetsAsync.valueOrNull ?? const [],
        sessionTotalsAsync.valueOrNull ?? const <String, int>{},
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Budget> budgets,
    Map<String, int> sessionSpentByBudget,
  ) {
    final theme = Theme.of(context);
    final viewData = _buildBudgetsViewData(budgets, sessionSpentByBudget);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Budgets',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 52),
              ),
              const Spacer(),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Managing ${viewData.activeItems.length} active allocations for ${_monthYearLabel(DateTime.now())}.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4D4942),
            ),
          ),
          if (viewData.activeItems.isEmpty &&
              viewData.inactiveItems.isEmpty) ...[
            const SizedBox(height: 36),
            EmptyBudgetsCard(onCreatePressed: _openCreateDialog),
          ] else ...[
            const SizedBox(height: 22),
            if (viewData.activeItems.isNotEmpty) ...[
              BudgetOverviewCard(
                remainingAmountText: _money(viewData.remainingTotal),
                utilization: viewData.averageUtilization,
                statusLabel: viewData.overallStatus.label,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'ACTIVE BUDGETS',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.filter_list, size: 18),
                  const SizedBox(width: 14),
                  const Icon(Icons.tune, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              ...viewData.activeItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BudgetAllocationCard(
                    icon: _iconForType(item.budget.type),
                    name: item.budget.name,
                    spentText: _money(item.spent),
                    totalText: _money(item.budget.amount),
                    utilization: item.utilization,
                    utilizationText:
                        '${(item.utilization * 100).toStringAsFixed(0)}% used',
                    leftText:
                        '${item.left < 0 ? '-' : ''}${_money(item.left.abs())} left',
                    isNegativeLeft: item.left < 0,
                    statusLabel: item.status.label,
                    statusBadgeBg: item.status.badgeBg,
                    statusBadgeColor: item.status.badgeColor,
                    onTap: () => widget.onOpenActiveSession(item.budget),
                    onEdit: () => _openEditDialog(item.budget),
                    onDelete: () => _confirmDelete(item.budget),
                  ),
                ),
              ),
            ],
            if (viewData.inactiveItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'INACTIVE BUDGETS',
                style: theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A948B),
                ),
              ),
              const SizedBox(height: 12),
              ...viewData.inactiveItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BudgetAllocationCard(
                    icon: _iconForType(item.budget.type),
                    name: item.budget.name,
                    spentText: _money(item.spent),
                    totalText: _money(item.budget.amount),
                    utilization: item.utilization,
                    utilizationText:
                        '${(item.utilization * 100).toStringAsFixed(0)}% used',
                    leftText:
                        '${item.left < 0 ? '-' : ''}${_money(item.left.abs())} unused',
                    isNegativeLeft: item.left < 0,
                    statusLabel: item.status.label,
                    statusBadgeBg: item.status.badgeBg,
                    statusBadgeColor: item.status.badgeColor,
                    isInactive: true,
                    onEdit: () => _openEditDialog(item.budget),
                    onDelete: () => _confirmDelete(item.budget),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    await _openBudgetDialog();
  }

  Future<void> _openEditDialog(Budget budget) async {
    await _openBudgetDialog(initial: budget);
  }

  Future<void> _openBudgetDialog({Budget? initial}) async {
    final defaultWarningPercent =
        ref.read(appPrimaryWarningLevelProvider).valueOrNull ?? 80.0;
    final result = await showModalBottomSheet<_BudgetFormValue>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8F7F4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (context) => _BudgetFormDialog(
        initial: initial,
        defaultWarningPercent: defaultWarningPercent,
      ),
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();
    final payload = Budget(
      id: initial?.id ?? 'budget_${now.microsecondsSinceEpoch}',
      name: result.name.trim(),
      type: result.type,
      amount: result.amount,
      warningPercent: result.warningPercent,
      isActive: result.isActive,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(budgetListProvider.notifier);
    if (initial == null) {
      await notifier.addBudget(payload);
      return;
    }
    await notifier.updateBudget(payload);
  }

  Future<void> _confirmDelete(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFC41212),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Delete Budget?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'You are about to delete ${budget.name}. This action will permanently remove all associated transaction history and cannot be undone.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5A5751),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E2DD),
                    foregroundColor: const Color(0xFF2E2C29),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(budgetListProvider.notifier).deleteBudget(budget.id);
    }
  }
}

class _BudgetFormDialog extends StatefulWidget {
  const _BudgetFormDialog({this.initial, required this.defaultWarningPercent});

  final Budget? initial;
  final double defaultWarningPercent;

  @override
  State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<_BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  BudgetType? _selectedType;
  late double _warningPercent;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _amountController = TextEditingController(
      text: initial != null
          ? MoneyUtils.centavosToInputValue(initial.amount)
          : '',
    );
    _warningPercent = initial?.warningPercent ?? widget.defaultWarningPercent;
    _selectedType = _normalizeSelectableType(initial?.type);
    _isActive = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.92;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
                child: Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Budget' : 'New Budget',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 32),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FieldLabelText('Budget Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'e.g.,  Groceries',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a budget name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabelText('Total Amount'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      prefixText:
                                          '${MoneyUtils.currencySymbol} ',
                                      hintText: '0.00',
                                    ),
                                    validator: (value) {
                                      final parsed = _parseCurrency(value);
                                      if (parsed == null || parsed <= 0) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabelText('Category'),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<BudgetType?>(
                                    initialValue: _selectedType,
                                    items: [
                                      ..._selectableBudgetTypes.map(
                                        (type) => DropdownMenuItem<BudgetType?>(
                                          value: type,
                                          child: Text(_labelForType(type)),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _selectedType = value);
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F0EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabelText('Active'),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isActive
                                          ? 'Included in active budgets'
                                          : 'Hidden from active budgets',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF6A665F),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() => _isActive = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const _FieldLabelText('Warning Threshold'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9E6E1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_warningPercent.toStringAsFixed(0)}%',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                          ),
                          child: Slider(
                            value: _warningPercent,
                            min: 0,
                            max: 100,
                            onChanged: (value) {
                              setState(() => _warningPercent = value);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            children: [
                              Text('0%', style: theme.textTheme.bodyMedium),
                              const Spacer(),
                              Text('50%', style: theme.textTheme.bodyMedium),
                              const Spacer(),
                              Text('100%', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We'll notify you when spending reaches this level.",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6A665F),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: theme.textTheme.titleMedium),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2D2D2D), Color(0xFF101010)],
                        ),
                      ),
                      child: TextButton(
                        onPressed: _onSubmit,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Save Budget' : 'Create Budget',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = _parseCurrency(_amountController.text);
    if (amount == null || amount <= 0 || _selectedType == null) {
      return;
    }

    Navigator.pop(
      context,
      _BudgetFormValue(
        name: _nameController.text,
        type: _selectedType!,
        amount: amount,
        warningPercent: _warningPercent,
        isActive: _isActive,
      ),
    );
  }

  int? _parseCurrency(String? raw) {
    if (raw == null) {
      return null;
    }
    return MoneyUtils.parseCurrencyToCentavos(raw);
  }
}

class _BudgetFormValue {
  const _BudgetFormValue({
    required this.name,
    required this.type,
    required this.amount,
    required this.warningPercent,
    required this.isActive,
  });

  final String name;
  final BudgetType type;
  final int amount;
  final double warningPercent;
  final bool isActive;
}

class _FieldLabelText extends StatelessWidget {
  const _FieldLabelText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
