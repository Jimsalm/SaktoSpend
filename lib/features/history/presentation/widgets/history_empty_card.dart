import 'package:flutter/material.dart';

class HistoryEmptyCard extends StatelessWidget {
  const HistoryEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 42,
              color: Color(0xFF8D8880),
            ),
            const SizedBox(height: 10),
            Text(
              'No history yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your previous budgets will appear here.',
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
