import 'package:flutter/material.dart';

class EmptyCartPlaceholder extends StatelessWidget {
  const EmptyCartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEEA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_basket_outlined, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan a barcode or add an item\nmanually to get started.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF66635C),
            ),
          ),
        ],
      ),
    );
  }
}
