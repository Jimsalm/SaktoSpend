import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyBudgetsCard extends StatelessWidget {
  const EmptyBudgetsCard({super.key, required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -0.18,
                  child: Transform.translate(
                    offset: const Offset(-46, -8),
                    child: _FloatIconCard(icon: Icons.landscape_outlined),
                  ),
                ),
                Transform.rotate(
                  angle: 0.14,
                  child: Transform.translate(
                    offset: const Offset(52, -46),
                    child: _FloatIconCard(icon: Icons.payments_outlined),
                  ),
                ),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: tokens.surfacePrimary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        offset: Offset(0, 6),
                        color: tokens.shadowColor,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    size: 46,
                    color: Color(0xFF69A80D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'No Active Budgets',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 44,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't set any budgets for this month. Start by creating your first budget allocation.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFA4ED23),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 3),
                  color: tokens.shadowColor,
                ),
              ],
            ),
            child: TextButton(
              onPressed: onCreatePressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D1530),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                '+  Create First Budget',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF0D1530),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.surfacePrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: tokens.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'TIP: BUDGETS HELP YOU SAVE 20% MORE MONTHLY',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatIconCard extends StatelessWidget {
  const _FloatIconCard({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: tokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24, color: tokens.textSecondary),
    );
  }
}
