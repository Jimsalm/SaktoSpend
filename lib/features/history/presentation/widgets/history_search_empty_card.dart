import 'package:flutter/material.dart';

class HistorySearchEmptyCard extends StatelessWidget {
  const HistorySearchEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Color(0xFF8D8880),
            ),
            const SizedBox(height: 10),
            Text(
              'No matching budgets',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another keyword.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6A665F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
