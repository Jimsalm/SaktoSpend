import 'package:flutter/material.dart';

class HomeOverviewScreen extends StatelessWidget {
  const HomeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            const SizedBox(height: 28),
            Text(
              'MARCH 2024',
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 2.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Overview',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 52,
                height: 0.98,
              ),
            ),
            const SizedBox(height: 20),
            const _SimpleCard(
              title: 'WEEKLY GROCERIES',
              primary: '\$120.40',
              secondary: '/ \$150.00',
              noteLeft: '80% consumed',
              noteRight: '\$29.60 left',
            ),
            const SizedBox(height: 14),
            const _SimpleCard(
              title: 'MONTHLY SURPLUS',
              primary: '\$2,410.00',
              badge: '+12% FROM LAST MONTH',
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Text('Spending Insights', style: theme.textTheme.titleLarge),
                const Spacer(),
                Text(
                  'View Details',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _InsightsCard(),
            const SizedBox(height: 26),
            Row(
              children: [
                Text('Recent Sessions', style: theme.textTheme.titleLarge),
                const Spacer(),
                const Icon(Icons.tune, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            ..._sampleSessions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SessionTile(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          'Home',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 52,
          ),
        ),
        const Spacer(),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.primary,
    this.secondary,
    this.badge,
    this.noteLeft,
    this.noteRight,
  });

  final String title;
  final String primary;
  final String? secondary;
  final String? badge;
  final String? noteLeft;
  final String? noteRight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: primary,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 45),
                  ),
                  if (secondary != null)
                    TextSpan(
                      text: ' $secondary',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF59554D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7E1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: const Color(0xFF34322E),
                  ),
                ),
              ),
            ],
            if (noteLeft != null && noteRight != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(
                  minHeight: 8,
                  value: 0.8,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF111111)),
                  backgroundColor: Color(0xFFE2DFD9),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    noteLeft!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF35322D),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    noteRight!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF35322D),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 182,
                height: 182,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 182,
                      height: 182,
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 11,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF111111),
                        ),
                        backgroundColor: const Color(0xFFD8D5CF),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '75%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 42,
                          ),
                        ),
                        Text(
                          'TARGET',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const _InsightRow(
              dotColor: Color(0xFF111111),
              label: 'Fixed Expenses',
              amount: '\$3,200',
            ),
            const SizedBox(height: 12),
            const _InsightRow(
              dotColor: Color(0xFFD8D5CF),
              label: 'Variable Costs',
              amount: '\$1,080',
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF46423B),
                ),
                children: [
                  const TextSpan(text: 'Your spending on '),
                  TextSpan(
                    text: 'Leisure',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text: ' is 15% lower than your 3-month average.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.dotColor,
    required this.label,
    required this.amount,
  });

  final Color dotColor;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          amount,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.item});

  final _SessionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} • ${item.when}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.amount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionItem {
  const _SessionItem({
    required this.icon,
    required this.title,
    required this.category,
    required this.when,
    required this.amount,
  });

  final IconData icon;
  final String title;
  final String category;
  final String when;
  final String amount;
}

const _sampleSessions = <_SessionItem>[
  _SessionItem(
    icon: Icons.coffee_outlined,
    title: 'Blue Bottle Coffee',
    category: 'LIFESTYLE',
    when: 'TODAY',
    amount: '-\$6.50',
  ),
  _SessionItem(
    icon: Icons.directions_bus_filled_outlined,
    title: 'Metropolitan Transit',
    category: 'TRANSPORT',
    when: 'YESTERDAY',
    amount: '-\$2.75',
  ),
  _SessionItem(
    icon: Icons.account_balance,
    title: 'Monthly Dividend',
    category: 'INVESTMENT',
    when: '2 DAYS AGO',
    amount: '+\$45.20',
  ),
  _SessionItem(
    icon: Icons.receipt_long_outlined,
    title: 'Whole Foods Market',
    category: 'GROCERIES',
    when: '3 DAYS AGO',
    amount: '-\$84.12',
  ),
];
