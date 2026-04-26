part of '../screens/scan_review_screen.dart';

class _EntryForm extends StatelessWidget {
  const _EntryForm({
    required this.isScannedDraft,
    required this.hardBudgetModeEnabled,
    required this.nameController,
    required this.priceController,
    required this.categories,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.isEssential,
    required this.total,
    required this.budgetTotal,
    required this.budgetRemainingBeforeEntry,
    required this.onClose,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onDecreaseQty,
    required this.onIncreaseQty,
    required this.onUnitChanged,
    required this.onEssentialChanged,
    required this.onConfirm,
  });

  final bool isScannedDraft;
  final bool hardBudgetModeEnabled;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final List<String> categories;
  final String category;
  final int quantity;
  final String unit;
  final bool isEssential;
  final int total;
  final int budgetTotal;
  final int budgetRemainingBeforeEntry;
  final VoidCallback onClose;
  final VoidCallback onChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onDecreaseQty;
  final VoidCallback onIncreaseQty;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<bool> onEssentialChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final remaining = budgetRemainingBeforeEntry - total;
    final safeBudgetBase = budgetTotal > 0
        ? budgetTotal
        : (budgetRemainingBeforeEntry > 0 ? budgetRemainingBeforeEntry : 0);
    final spentAfterEntry = safeBudgetBase - remaining;
    final progress = safeBudgetBase <= 0
        ? 0.0
        : (spentAfterEntry / safeBudgetBase).clamp(0.0, 1.0).toDouble();
    final exceedsHardLimit = hardBudgetModeEnabled && remaining < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: tokens.borderSubtle,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Entry',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 34,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Confirm the label details, adjust anything needed, and then add the item to your cart.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _EntrySheetIconButton(icon: Icons.close_rounded, onTap: onClose),
          ],
        ),
        const SizedBox(height: 18),
        _EntryHeroCard(
          isScannedDraft: isScannedDraft,
          isEssential: isEssential,
        ),
        const SizedBox(height: 16),
        _EntrySectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _EntrySectionTitle(
                title: 'Item Details',
                subtitle:
                    'Set the product name, category, and unit price that should be saved for this label.',
              ),
              const SizedBox(height: 18),
              const _EntryFieldLabel('Product Name'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                onChanged: (_) => onChanged(),
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Organic Almond Milk',
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final categoryField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _EntryFieldLabel('Category'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        isExpanded: true,
                        dropdownColor: tokens.surfacePrimary,
                        borderRadius: BorderRadius.circular(18),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: tokens.textSecondary,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: tokens.textPrimary,
                        ),
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
                        onChanged: onCategoryChanged,
                        decoration: const InputDecoration(),
                      ),
                    ],
                  );

                  final priceField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _EntryFieldLabel('Unit Price'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        onChanged: (_) => onChanged(),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          prefixText: '${MoneyUtils.currencySymbol} ',
                          hintText: '0.00',
                        ),
                      ),
                    ],
                  );

                  if (constraints.maxWidth < 420) {
                    return Column(
                      children: [
                        categoryField,
                        const SizedBox(height: 14),
                        priceField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: categoryField),
                      const SizedBox(width: 12),
                      Expanded(child: priceField),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _EntrySectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _EntrySectionTitle(
                title: 'Quantity & Settings',
                subtitle:
                    'Fine-tune quantity, unit, and whether this label belongs to an essential item.',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _EntryFieldLabel('Quantity'),
                        const SizedBox(height: 8),
                        _EntrySurface(
                          child: Row(
                            children: [
                              _EntryTapButton(
                                icon: Icons.remove_rounded,
                                onTap: onDecreaseQty,
                              ),
                              const Spacer(),
                              Text(
                                '$quantity',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 30,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              _EntryTapButton(
                                icon: Icons.add_rounded,
                                onTap: onIncreaseQty,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _EntryFieldLabel('Unit'),
                        const SizedBox(height: 8),
                        _EntrySurface(
                          child: Row(
                            children: [
                              Expanded(
                                child: _EntrySegmentButton(
                                  label: 'PC',
                                  selected: unit == 'PC',
                                  onTap: () => onUnitChanged('PC'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _EntrySegmentButton(
                                  label: 'KG',
                                  selected: unit == 'KG',
                                  onTap: () => onUnitChanged('KG'),
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
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.borderSubtle),
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
                        Icons.shield_rounded,
                        color: isEssential
                            ? tokens.accentStrong
                            : tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Essential Item',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep important items grouped at the top of the shopping session.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch.adaptive(
                      value: isEssential,
                      onChanged: onEssentialChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _EntryImpactCard(
          totalText: _money(total),
          remainingText:
              '${remaining < 0 ? '-' : ''}${_money(remaining.abs())}',
          progress: progress,
          exceedsHardLimit: exceedsHardLimit,
        ),
        if (exceedsHardLimit) ...[
          const SizedBox(height: 10),
          Text(
            'Hard Budget Mode is enabled. Reduce the total cost to continue.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.warningStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onClose,
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
                onPressed: exceedsHardLimit ? null : onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.accentStrong,
                  foregroundColor: tokens.textPrimary,
                  disabledBackgroundColor: tokens.surfaceElevated,
                  disabledForegroundColor: tokens.textTertiary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm Entry',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: exceedsHardLimit
                        ? tokens.textTertiary
                        : tokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EntrySheetIconButton extends StatelessWidget {
  const _EntrySheetIconButton({required this.icon, required this.onTap});

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

class _EntryHeroCard extends StatelessWidget {
  const _EntryHeroCard({
    required this.isScannedDraft,
    required this.isEssential,
  });

  final bool isScannedDraft;
  final bool isEssential;

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
                  isScannedDraft ? 'LABEL DRAFT' : 'MANUAL DRAFT',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isScannedDraft
                      ? 'Review the OCR result and clean up anything the label scan missed.'
                      : 'Enter the label details manually before sending the item into your cart.',
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
                    _ScannerTag(
                      icon: isScannedDraft
                          ? Icons.document_scanner_outlined
                          : Icons.edit_note_rounded,
                      label: isScannedDraft ? 'Label Scan' : 'Manual Entry',
                      backgroundColor: tokens.surfaceSecondary,
                      foregroundColor: tokens.textSecondary,
                    ),
                    _ScannerTag(
                      icon: isEssential
                          ? Icons.shield_rounded
                          : Icons.inventory_2_outlined,
                      label: isEssential ? 'Essential' : 'Standard Item',
                      backgroundColor: isEssential
                          ? tokens.accentSoft
                          : tokens.surfaceSecondary,
                      foregroundColor: isEssential
                          ? const Color(0xFF5F950D)
                          : tokens.textSecondary,
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
              Icons.receipt_long_rounded,
              color: tokens.accentStrong,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntrySectionCard extends StatelessWidget {
  const _EntrySectionCard({required this.child});

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

class _EntrySectionTitle extends StatelessWidget {
  const _EntrySectionTitle({required this.title, required this.subtitle});

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

class _EntryFieldLabel extends StatelessWidget {
  const _EntryFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EntrySurface extends StatelessWidget {
  const _EntrySurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: child,
    );
  }
}

class _EntryTapButton extends StatelessWidget {
  const _EntryTapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Icon(icon, size: 18, color: tokens.textPrimary),
        ),
      ),
    );
  }
}

class _EntrySegmentButton extends StatelessWidget {
  const _EntrySegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? tokens.accentStrong : tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? tokens.accentStrong : tokens.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryImpactCard extends StatelessWidget {
  const _EntryImpactCard({
    required this.totalText,
    required this.remainingText,
    required this.progress,
    required this.exceedsHardLimit,
  });

  final String totalText;
  final String remainingText;
  final double progress;
  final bool exceedsHardLimit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final accentColor = exceedsHardLimit
        ? tokens.warningStrong
        : const Color(0xFF69A80D);

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
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(0.9, -0.06),
          radius: 1.05,
          colors: [
            (exceedsHardLimit ? tokens.warningSoft : tokens.accentSoft)
                .withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.97),
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Budget Impact',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress.clamp(0.0, 1.0).toDouble() * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 14, color: const Color(0xFFD9E0EB)),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: exceedsHardLimit
                            ? const [Color(0xFFF46B66), Color(0xFFFFA19C)]
                            : const [Color(0xFF98EA1B), Color(0xFFC9F96E)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ImpactMetric(
                  label: 'TOTAL COST',
                  value: totalText,
                  valueColor: tokens.textPrimary,
                ),
              ),
              Expanded(
                child: _ImpactMetric(
                  label: exceedsHardLimit ? 'OVER LIMIT' : 'REMAINING',
                  value: remainingText,
                  valueColor: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  const _ImpactMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.4,
            color: tokens.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
