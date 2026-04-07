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
    final titleColor = isInactive ? const Color(0xFF8E897F) : null;
    final bodyColor = isInactive ? const Color(0xFFA29D94) : const Color(0xFF36322C);
    final iconBg = isInactive ? const Color(0xFFF4F2EE) : const Color(0xFFF0EEEA);
    final iconColor = isInactive ? const Color(0xFFA9A39A) : null;
    final barValueColor = isInactive ? const Color(0xFF8E897F) : const Color(0xFF111111);
    final barTrackColor = isInactive ? const Color(0xFFE9E6E0) : const Color(0xFFE2DFD9);
    final leftColor = isInactive
        ? const Color(0xFFA29D94)
        : isNegativeLeft
            ? const Color(0xFFBB1414)
            : const Color(0xFF3C3832);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
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
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$spentText of $totalText',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: bodyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<_BudgetCardMenuAction>(
                        padding: EdgeInsets.zero,
                        color: const Color(0xFFF1ECE2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(Icons.more_vert, size: 20),
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
                                  color: Color(0xFF7D7870),
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
                                  color: Color(0xFFC41212),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Color(0xFFC41212)),
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
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: utilization.clamp(0.0, 1.0).toDouble(),
                  valueColor: AlwaysStoppedAnimation(barValueColor),
                  backgroundColor: barTrackColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    utilizationText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isInactive
                          ? const Color(0xFFA29D94)
                          : const Color(0xFF3C3832),
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
  });

  final String label;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
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
