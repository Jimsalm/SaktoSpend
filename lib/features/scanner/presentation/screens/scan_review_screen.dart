import 'package:flutter/material.dart';

class ScanReviewScreen extends StatelessWidget {
  const ScanReviewScreen({
    super.key,
    required this.onBack,
    required this.onAddToCart,
  });

  final VoidCallback onBack;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'The Budget Curator',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 28),
                ),
                const Spacer(),
                const Icon(Icons.search, size: 22),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF584A3A), Color(0xFF8D765F), Color(0xFFC3AB8E)],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 48,
                  right: 48,
                  top: 80,
                  bottom: 280,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.55)),
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(
                          height: 2,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CameraTool(icon: Icons.flash_on, onTap: () {}),
                      const SizedBox(width: 16),
                      _CameraTool(icon: Icons.cameraswitch_outlined, onTap: () {}),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F5F3),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D6D1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text('Item Details', style: theme.textTheme.titleLarge?.copyWith(fontSize: 42)),
                          const SizedBox(height: 6),
                          Text(
                            'Scanning complete. Please verify the information below.',
                            style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF4D4A44)),
                          ),
                          const SizedBox(height: 18),
                          const _FieldLabel('PRODUCT NAME'),
                          const SizedBox(height: 6),
                          const _InputLike(child: Text('Premium Italian Roast Beans')),
                          const SizedBox(height: 14),
                          const _FieldLabel('CATEGORY'),
                          const SizedBox(height: 6),
                          const _InputLike(
                            child: Row(
                              children: [
                                Text('Groceries'),
                                Spacer(),
                                Icon(Icons.expand_more),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('UNIT PRICE'),
                                    SizedBox(height: 6),
                                    _InputLike(child: Text('\$  24.50')),
                                  ],
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('QUANTITY'),
                                    SizedBox(height: 6),
                                    _InputLike(
                                      child: Row(
                                        children: [
                                          Text('-'),
                                          Spacer(),
                                          Text('1'),
                                          Spacer(),
                                          Text('+'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _SummaryPanel(
                            title: 'NEW TOTAL',
                            value: '\$452.20',
                            sideValue: '+\$24.50',
                            sideRed: true,
                            progress: 0,
                          ),
                          const SizedBox(height: 10),
                          const _SummaryPanel(
                            title: 'BUDGET REMAINING',
                            value: '\$147.80',
                            progress: 0.72,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 66,
                            child: FilledButton.icon(
                              onPressed: onAddToCart,
                              icon: const Icon(Icons.add_shopping_cart, size: 26),
                              label: const Text('Add to Cart'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                textStyle: theme.textTheme.titleLarge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _CameraTool extends StatelessWidget {
  const _CameraTool({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.28),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        letterSpacing: 2.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InputLike extends StatelessWidget {
  const _InputLike({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE7E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.title,
    required this.value,
    this.sideValue,
    this.sideRed = false,
    required this.progress,
  });

  final String title;
  final String value;
  final String? sideValue;
  final bool sideRed;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE7E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 54),
              ),
              if (sideValue != null) ...[
                const SizedBox(width: 8),
                Text(
                  sideValue!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: sideRed ? const Color(0xFFC71111) : const Color(0xFF3D3A34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          if (progress > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progress,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF111111)),
                backgroundColor: const Color(0xFFD8D5CF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
