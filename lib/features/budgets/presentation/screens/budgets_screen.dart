import 'package:budget_tracker/app/providers/providers.dart';
import 'package:budget_tracker/domain/entities/budget.dart';
import 'package:budget_tracker/domain/entities/budget_health.dart';
import 'package:budget_tracker/domain/usecases/budget_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Budget Tracker'),
      ),
      body: budgets.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No budgets yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('Create your first budget to start tracking.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openBudgetForm(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final budget = items[index];
              final warningAmount = BudgetCalculator.warningThresholdAmount(
                budgetAmount: budget.amount,
                warningPercent: budget.warningPercent,
              );
              final status = _statusFromBudget(budget);

              return Card(
                child: ListTile(
                  onTap: () => _openBudgetForm(context, ref, initial: budget),
                  title: Text(
                    budget.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${budget.type.name.toUpperCase()}'
                      '  •  Amount: ${_money(budget.amount)}'
                      '  •  Reserve: ${_money(budget.reserveAmount)}\n'
                      'Warn at ${budget.warningPercent.toStringAsFixed(0)}%'
                      ' (${_money(warningAmount)})'
                      '  •  ${budget.isActive ? 'Active' : 'Inactive'}',
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(status),
                    child: Icon(
                      _statusIcon(status),
                      color: Colors.white,
                    ),
                  ),
                  trailing: PopupMenuButton<_BudgetMenuAction>(
                    onSelected: (action) async {
                      if (action == _BudgetMenuAction.edit) {
                        await _openBudgetForm(context, ref, initial: budget);
                        return;
                      }
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete budget'),
                          content: Text('Delete "${budget.name}" permanently?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref
                            .read(budgetListProvider.notifier)
                            .deleteBudget(budget.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _BudgetMenuAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: _BudgetMenuAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load budgets: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBudgetForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Budget'),
      ),
    );
  }

  Future<void> _openBudgetForm(
    BuildContext context,
    WidgetRef ref, {
    Budget? initial,
  }) async {
    final result = await showDialog<_BudgetFormValue>(
      context: context,
      builder: (context) => _BudgetFormDialog(initial: initial),
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();
    final budget = Budget(
      id: initial?.id ?? 'budget_${now.microsecondsSinceEpoch}',
      name: result.name.trim(),
      type: result.type,
      amount: result.amount,
      reserveAmount: result.reserveAmount,
      warningPercent: result.warningPercent,
      startDate: result.startDate,
      endDate: result.endDate,
      isActive: result.isActive,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    if (initial == null) {
      await ref.read(budgetListProvider.notifier).addBudget(budget);
      return;
    }
    await ref.read(budgetListProvider.notifier).updateBudget(budget);
  }

  BudgetHealth _statusFromBudget(Budget budget) {
    return BudgetCalculator.healthFromSpent(
      budgetAmount: budget.amount,
      spentAmount: 0,
      warningPercent: budget.warningPercent,
    );
  }

  Color _statusColor(BudgetHealth status) {
    switch (status) {
      case BudgetHealth.safe:
        return Colors.green;
      case BudgetHealth.warning:
        return Colors.orange;
      case BudgetHealth.exceeded:
        return Colors.red;
    }
  }

  IconData _statusIcon(BudgetHealth status) {
    switch (status) {
      case BudgetHealth.safe:
        return Icons.check;
      case BudgetHealth.warning:
        return Icons.warning_rounded;
      case BudgetHealth.exceeded:
        return Icons.error;
    }
  }
}

enum _BudgetMenuAction { edit, delete }

String _money(double value) => '\$${value.toStringAsFixed(2)}';

class _BudgetFormDialog extends StatefulWidget {
  const _BudgetFormDialog({this.initial});

  final Budget? initial;

  @override
  State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<_BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _reserveController;
  late final TextEditingController _warningController;
  late BudgetType _type;
  late bool _isActive;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final now = DateTime.now();

    _nameController = TextEditingController(text: initial?.name ?? '');
    _amountController = TextEditingController(
      text: initial != null ? initial.amount.toStringAsFixed(2) : '',
    );
    _reserveController = TextEditingController(
      text: initial != null ? initial.reserveAmount.toStringAsFixed(2) : '0.00',
    );
    _warningController = TextEditingController(
      text: initial != null ? initial.warningPercent.toStringAsFixed(0) : '80',
    );
    _type = initial?.type ?? BudgetType.trip;
    _isActive = initial?.isActive ?? true;
    _startDate = initial?.startDate ?? now;
    _endDate = initial?.endDate ?? now.add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _reserveController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit budget' : 'Create budget'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Budget name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a budget name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BudgetType>(
                  value: _type,
                  items: BudgetType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _type = value);
                  },
                  decoration: const InputDecoration(labelText: 'Budget type'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Budget amount'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reserveController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Reserve amount'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed < 0) {
                      return 'Reserve must be 0 or higher';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _warningController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Warning threshold (%)',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed < 0 || parsed > 100) {
                      return 'Use a value between 0 and 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isActive,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('Budget active'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start date'),
                  subtitle: Text(_dateLabel(_startDate)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: _startDate,
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End date'),
                  subtitle: Text(_dateLabel(_endDate)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: _startDate,
                      lastDate: DateTime(2100),
                      initialDate: _endDate.isBefore(_startDate)
                          ? _startDate
                          : _endDate,
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSubmit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final reserve = double.parse(_reserveController.text);
    final warning = double.parse(_warningController.text);

    if (reserve > amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserve amount cannot be greater than budget amount.'),
        ),
      );
      return;
    }

    final payload = _BudgetFormValue(
      name: _nameController.text,
      type: _type,
      amount: amount,
      reserveAmount: reserve,
      warningPercent: warning,
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
    );

    Navigator.pop(context, payload);
  }
}

class _BudgetFormValue {
  const _BudgetFormValue({
    required this.name,
    required this.type,
    required this.amount,
    required this.reserveAmount,
    required this.warningPercent,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  final String name;
  final BudgetType type;
  final double amount;
  final double reserveAmount;
  final double warningPercent;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
}

String _dateLabel(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
