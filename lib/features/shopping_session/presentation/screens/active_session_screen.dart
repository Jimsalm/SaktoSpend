import 'package:flutter/material.dart';

class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({
    super.key,
    required this.onOpenScanner,
  });

  final VoidCallback onOpenScanner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The Budget Curator',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 30),
                  ),
                ),
                const Icon(Icons.search, size: 22),
              ],
            ),
            const SizedBox(height: 16),
            const _RemainingShieldCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                Text('Active Cart', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 52)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5DF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '4 ITEMS',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _activeCartItems.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CartItemTile(item: _activeCartItems[index]),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 66,
                    child: FilledButton.icon(
                      onPressed: onOpenScanner,
                      icon: const Icon(Icons.qr_code_scanner, size: 26),
                      label: const Text('Scan Barcode'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        textStyle: theme.textTheme.titleLarge,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 78,
                  height: 66,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE0DDD8),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Icon(Icons.add, size: 34),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RemainingShieldCard extends StatelessWidget {
  const _RemainingShieldCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            'REMAINING SHIELD',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$428.50',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 84,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              minHeight: 10,
              value: 0.66,
              valueColor: AlwaysStoppedAnimation(Color(0xFFF0F0F0)),
              backgroundColor: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Spent \$214.20 of \$642.70',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF898989),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final _CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 30, color: const Color(0xFF3F3F3F)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleLarge?.copyWith(fontSize: 46)),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF52504B),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.price,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 44),
                ),
                const SizedBox(height: 2),
                Text(
                  'QTY: ${item.quantity}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    letterSpacing: 1.1,
                    color: const Color(0xFF44413B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem {
  const _CartItem({
    required this.icon,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
  });

  final IconData icon;
  final String name;
  final String category;
  final String price;
  final int quantity;
}

const _activeCartItems = <_CartItem>[
  _CartItem(
    icon: Icons.coffee,
    name: 'Artisan Whole Bean Coffee',
    category: 'Pantry & Grains',
    price: '\$18.00',
    quantity: 1,
  ),
  _CartItem(
    icon: Icons.bakery_dining,
    name: 'Organic Sourdough Bread',
    category: 'Fresh Bakery',
    price: '\$9.50',
    quantity: 2,
  ),
  _CartItem(
    icon: Icons.water_drop,
    name: 'Sparkling Mineral Water',
    category: 'Beverages',
    price: '\$12.00',
    quantity: 4,
  ),
  _CartItem(
    icon: Icons.local_florist,
    name: 'Greek Yogurt Pack',
    category: 'Dairy',
    price: '\$14.20',
    quantity: 1,
  ),
];
