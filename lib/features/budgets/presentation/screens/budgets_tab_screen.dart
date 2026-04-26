import 'dart:math' as math;

import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/theme/app_theme.dart';
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
    final tokens = context.appThemeTokens;
    final viewData = _buildBudgetsViewData(budgets, sessionSpentByBudget);

    return SingleChildScrollView(
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
                    'Budgets',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 42,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _monthYearLabel(DateTime.now()),
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
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Managing ${viewData.activeItems.length} active allocations for ${_monthYearLabel(DateTime.now())}.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.textSecondary,
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
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'ACTIVE BUDGETS',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w700,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: tokens.textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: tokens.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...viewData.activeItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
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
              const SizedBox(height: 8),
              Text(
                'INACTIVE BUDGETS',
                style: theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                  color: tokens.textTertiary,
                ),
              ),
              const SizedBox(height: 14),
              ...viewData.inactiveItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
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
      backgroundColor: Colors.transparent,
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
    final tokens = context.appThemeTokens;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.92;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          decoration: BoxDecoration(
            color: tokens.backgroundCanvas,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Budget' : 'New Budget',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 34,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEditing
                                ? 'Refine the amount, type, and warning level for this budget.'
                                : 'Set a spending limit, choose the budget type, and control alerts.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _SheetIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BudgetFormHeroCard(
                          typeLabel: _selectedType != null
                              ? _labelForType(_selectedType!)
                              : 'Budget',
                          isActive: _isActive,
                          isEditing: isEditing,
                        ),
                        const SizedBox(height: 16),
                        _BudgetFormSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormSectionTitle(
                                title: 'Budget Details',
                                subtitle:
                                    'Name this budget and set the total amount you want to manage.',
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabelText('Budget Name'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., Groceries',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a budget name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final amountField = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabelText('Total Amount'),
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
                                            return 'Enter a valid amount';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  );
                                  final categoryField = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabelText('Type'),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<BudgetType?>(
                                        initialValue: _selectedType,
                                        isExpanded: true,
                                        dropdownColor: tokens.surfacePrimary,
                                        borderRadius: BorderRadius.circular(18),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: tokens.textSecondary,
                                        ),
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: tokens.textPrimary,
                                            ),
                                        items: [
                                          ..._selectableBudgetTypes.map(
                                            (type) =>
                                                DropdownMenuItem<BudgetType?>(
                                                  value: type,
                                                  child: Text(
                                                    _labelForType(type),
                                                  ),
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
                                  );

                                  if (constraints.maxWidth < 420) {
                                    return Column(
                                      children: [
                                        amountField,
                                        const SizedBox(height: 14),
                                        categoryField,
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(child: amountField),
                                      const SizedBox(width: 12),
                                      Expanded(child: categoryField),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _BudgetFormSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormSectionTitle(
                                title: 'Budget Settings',
                                subtitle:
                                    'Control whether this budget is active and when the warning should appear.',
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: tokens.borderSubtle,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: tokens.surfacePrimary,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _isActive
                                            ? Icons.bolt_rounded
                                            : Icons.pause_circle_outline_rounded,
                                        color: _isActive
                                            ? tokens.accentStrong
                                            : tokens.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Active Budget',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color: tokens.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isActive
                                                ? 'Included in your active budget list and ready for shopping.'
                                                : 'Saved for later and hidden from the active budget list.',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: tokens.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  12,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: tokens.borderSubtle,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const _FieldLabelText(
                                          'Warning Threshold',
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: tokens.surfacePrimary,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: tokens.borderSubtle,
                                            ),
                                          ),
                                          child: Text(
                                            '${_warningPercent.toStringAsFixed(0)}%',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: tokens.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Slider(
                                      value: _warningPercent,
                                      min: 0,
                                      max: 100,
                                      onChanged: (value) {
                                        setState(() => _warningPercent = value);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '0%',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const Spacer(),
                                          Text(
                                            '50%',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const Spacer(),
                                          Text(
                                            '100%',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "We'll notify you when spending reaches this level.",
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: tokens.textSecondary,
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
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tokens.textPrimary,
                          backgroundColor: tokens.surfacePrimary,
                          side: BorderSide(color: tokens.borderSubtle),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.accentStrong,
                          foregroundColor: tokens.textPrimary,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isEditing ? 'Save Budget' : 'Create Budget',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w800,
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
    final tokens = context.appThemeTokens;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Icon(icon, color: tokens.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _BudgetFormHeroCard extends StatelessWidget {
  const _BudgetFormHeroCard({
    required this.typeLabel,
    required this.isActive,
    required this.isEditing,
  });

  final String typeLabel;
  final bool isActive;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
        gradient: RadialGradient(
          center: const Alignment(0.88, -0.08),
          radius: 1.1,
          colors: [
            tokens.accentSoft.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.97),
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'BUDGET UPDATE' : 'BUDGET SETUP',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isEditing
                      ? 'Keep this budget in sync with how you\'re spending now.'
                      : 'Build a budget that matches how you want to spend this month.',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroTag(
                      icon: Icons.layers_rounded,
                      label: typeLabel,
                    ),
                    _HeroTag(
                      icon: isActive
                          ? Icons.bolt_rounded
                          : Icons.pause_circle_outline_rounded,
                      label: isActive ? 'Active' : 'Inactive',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              shape: BoxShape.circle,
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: tokens.accentStrong,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetFormSectionCard extends StatelessWidget {
  const _BudgetFormSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
      child: child,
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: tokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
