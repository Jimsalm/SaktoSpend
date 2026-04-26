import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BudgetAllocationCard extends StatelessWidget {
  const BudgetAllocationCard({
    super.key,
    required this.icon,
    required this.name,
    required this.spentText,
    required this.totalText,
    required this.utilization,
    required this.utilizationText,
    required this.leftText,
    required this.isNegativeLeft,
    required this.statusLabel,
    required this.statusBadgeBg,
    required this.statusBadgeColor,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.isInactive = false,
  });

  final IconData icon;
  final String name;
  final String spentText;
  final String totalText;
  final double utilization;
  final String utilizationText;
  final String leftText;
  final bool isNegativeLeft;
  final String statusLabel;
  final Color statusBadgeBg;
  final Color statusBadgeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool isInactive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final titleColor = isInactive ? tokens.textTertiary : tokens.textPrimary;
    final bodyColor = isInactive ? tokens.textTertiary : tokens.textSecondary;
    final iconBg = isInactive ? tokens.surfaceSecondary : tokens.surfaceElevated;
    final iconColor = isInactive ? tokens.textTertiary : tokens.textPrimary;
    final barValueColor = isInactive
        ? tokens.textTertiary
        : const Color(0xFF93E71A);
    final barTrackColor = const Color(0xFFD9E0EB);
    final leftColor = isInactive
        ? tokens.textTertiary
        : isNegativeLeft
            ? tokens.warningStrong
            : tokens.textPrimary;

    return Container(
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
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$spentText of $totalText',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: bodyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<_BudgetCardMenuAction>(
                        padding: EdgeInsets.zero,
                        color: tokens.surfacePrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 22,
                          color: tokens.textSecondary,
                        ),
                        onSelected: (action) {
                          if (action == _BudgetCardMenuAction.edit) {
                            onEdit();
                            return;
                          }
                          onDelete();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: _BudgetCardMenuAction.edit,
                            height: 38,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Color(0xFF607496),
                                ),
                                SizedBox(width: 10),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuDivider(height: 8),
                          PopupMenuItem(
                            value: _BudgetCardMenuAction.delete,
                            height: 38,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Color(0xFFE52420),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Color(0xFFE52420)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _BudgetStatusBadge(
                        label: statusLabel,
                        bgColor: statusBadgeBg,
                        textColor: statusBadgeColor,
                        isInactive: isInactive,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: utilization.clamp(0.0, 1.0).toDouble(),
                  valueColor: AlwaysStoppedAnimation(barValueColor),
                  backgroundColor: barTrackColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    utilizationText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isInactive ? tokens.textTertiary : tokens.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    leftText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: leftColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BudgetCardMenuAction { edit, delete }

class _BudgetStatusBadge extends StatelessWidget {
  const _BudgetStatusBadge({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.isInactive,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final bool isInactive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isInactive ? bgColor.withValues(alpha: 0.82) : bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
