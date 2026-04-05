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
    return Scaffold(
      body: SafeArea(
        child: ref.watch(budgetListProvider).when(
              data: (items) => _BudgetWorkspace(
                items: items,
                onCreate: () => _openBudgetForm(context, ref),
                onEdit: (budget) => _openBudgetForm(context, ref, initial: budget),
                onDelete: (budget) => _deleteBudget(context, ref, budget),
              ),
              error: (error, _) => Center(child: Text('Failed to load budgets: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBudgetForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New budget'),
      ),
    );
  }

  Future<void> _openBudgetForm(BuildContext context, WidgetRef ref, {Budget? initial}) async {
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

  Future<void> _deleteBudget(BuildContext context, WidgetRef ref, Budget budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete budget'),
        content: Text('Delete "${budget.name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await ref.read(budgetListProvider.notifier).deleteBudget(budget.id);
    }
  }
}

class _BudgetWorkspace extends StatelessWidget {
  const _BudgetWorkspace({
    required this.items,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Budget> items;
  final VoidCallback onCreate;
  final ValueChanged<Budget> onEdit;
  final ValueChanged<Budget> onDelete;

  @override
  Widget build(BuildContext context) {
    final activeCount = items.where((budget) => budget.isActive).length;
    final totalAmount = items.fold<double>(0, (sum, budget) => sum + budget.amount);
    final totalReserve = items.fold<double>(0, (sum, budget) => sum + budget.reserveAmount);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          sliver: SliverToBoxAdapter(child: _PageHeader(onCreate: onCreate)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverToBoxAdapter(
            child: _OverviewRow(
              totalCount: items.length,
              activeCount: activeCount,
              totalAmount: totalAmount,
              totalReserve: totalReserve,
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _EmptyWorkspace(onCreate: onCreate),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final budget = items[index];
                final warningAmount = BudgetCalculator.warningThresholdAmount(
                  budgetAmount: budget.amount,
                  warningPercent: budget.warningPercent,
                );

                return Padding(
                  padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 10),
                  child: _BudgetBlock(
                    budget: budget,
                    warningAmount: warningAmount,
                    status: _statusFromBudget(budget),
                    onEdit: () => onEdit(budget),
                    onDelete: () => onDelete(budget),
                  ),
                );
              }, childCount: items.length),
            ),
          ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budgets', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'A clean workspace for planning shopping spend before each trip.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonalIcon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Add')),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.totalCount,
    required this.activeCount,
    required this.totalAmount,
    required this.totalReserve,
  });

  final int totalCount;
  final int activeCount;
  final double totalAmount;
  final double totalReserve;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _OverviewCard(label: 'Budgets', value: '$totalCount'),
          const SizedBox(width: 8),
          _OverviewCard(label: 'Active', value: '$activeCount'),
          const SizedBox(width: 8),
          _OverviewCard(label: 'Planned', value: _money(totalAmount)),
          const SizedBox(width: 8),
          _OverviewCard(label: 'Reserve', value: _money(totalReserve)),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: SizedBox(
        width: 142,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(value, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkspace extends StatelessWidget {
  const _EmptyWorkspace({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_add_outlined, size: 34),
            const SizedBox(height: 14),
            Text('No budgets yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Create your first budget and start a focused shopping session.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onCreate, child: const Text('Create budget')),
          ],
        ),
      ),
    );
  }
}

class _BudgetBlock extends StatelessWidget {
  const _BudgetBlock({
    required this.budget,
    required this.warningAmount,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final double warningAmount;
  final BudgetHealth status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _statusColor(status),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(_statusIcon(status), color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(budget.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        budget.isActive ? 'Active budget' : 'Inactive budget',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_BudgetMenuAction>(
                  onSelected: (action) => action == _BudgetMenuAction.edit ? onEdit() : onDelete(),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: _BudgetMenuAction.edit, child: Text('Edit')),
                    PopupMenuItem(value: _BudgetMenuAction.delete, child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MetaPill(label: budget.type.name.toUpperCase()),
                _MetaPill(label: 'Amount ${_money(budget.amount)}'),
                _MetaPill(label: 'Reserve ${_money(budget.reserveAmount)}'),
                _MetaPill(
                  label:
                      'Warning ${budget.warningPercent.toStringAsFixed(0)}% (${_money(warningAmount)})',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_dateLabel(budget.startDate)} to ${_dateLabel(budget.endDate)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label),
    );
  }
}

BudgetHealth _statusFromBudget(Budget budget) {
  if (budget.spendableAmount <= 0) {
    return BudgetHealth.exceeded;
  }
  if (!budget.isActive) {
    return BudgetHealth.warning;
  }
  return BudgetHealth.safe;
}

Color _statusColor(BudgetHealth status) {
  switch (status) {
    case BudgetHealth.safe:
      return const Color(0xFF5F7D60);
    case BudgetHealth.warning:
      return const Color(0xFF946C3D);
    case BudgetHealth.exceeded:
      return const Color(0xFF8A403A);
  }
}

IconData _statusIcon(BudgetHealth status) {
  switch (status) {
    case BudgetHealth.safe:
      return Icons.check;
    case BudgetHealth.warning:
      return Icons.pause;
    case BudgetHealth.exceeded:
      return Icons.close;
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
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Budget type'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Warning threshold (%)'),
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
                      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _onSubmit, child: Text(isEditing ? 'Save' : 'Create')),
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
        const SnackBar(content: Text('Reserve amount cannot be greater than budget amount.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _BudgetFormValue(
        name: _nameController.text,
        type: _type,
        amount: amount,
        reserveAmount: reserve,
        warningPercent: warning,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
      ),
    );
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
