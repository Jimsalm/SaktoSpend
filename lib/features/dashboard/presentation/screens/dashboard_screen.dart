import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 96),
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
              const _WeeklyGroceriesCard(),
              const SizedBox(height: 14),
              const _MonthlySurplusCard(),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D2D2D), Color(0xFF101010)],
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              spreadRadius: 0,
              offset: Offset(0, 6),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const _BottomNavBar(),
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
        const SizedBox(width: 14),
        const Icon(Icons.more_vert, size: 22),
      ],
    );
  }
}

class _WeeklyGroceriesCard extends StatelessWidget {
  const _WeeklyGroceriesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'WEEKLY GROCERIES',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.shopping_basket_outlined, size: 19),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: '\$120.40',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 45),
                  ),
                  TextSpan(
                    text: ' / \$150.00',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF59554D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: 0.8,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF111111)),
                backgroundColor: const Color(0xFFE2DFD9),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '80% consumed',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF35322D),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$29.60 left',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF35322D),
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

class _MonthlySurplusCard extends StatelessWidget {
  const _MonthlySurplusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'MONTHLY SURPLUS',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.trending_up, size: 19),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '\$2,410.00',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 49),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE7E1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+12% FROM LAST MONTH',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF34322E),
                ),
              ),
            ),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            const _TargetRing(progress: 0.75),
            const SizedBox(height: 22),
            const _InsightRow(
              dotColor: Color(0xFF0F0F0F),
              label: 'Fixed Expenses',
              value: '\$3,200',
            ),
            const SizedBox(height: 12),
            const _InsightRow(
              dotColor: Color(0xFFD1CEC8),
              label: 'Variable Costs',
              value: '\$1,080',
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
                  const TextSpan(text: ' is 15% lower than your 3-month average.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetRing extends StatelessWidget {
  const _TargetRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 156,
      height: 156,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 156,
            height: 156,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF111111)),
              backgroundColor: const Color(0xFFD8D5CF),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 32),
              ),
              Text(
                'TARGET',
                style: theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String value;

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
          value,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F3),
        border: Border(top: BorderSide(color: Color(0xFFE0DDD7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.home_rounded, label: 'Home', selected: true),
          _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Budgets'),
          SizedBox(width: 54),
          _NavItem(icon: Icons.history, label: 'History'),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF121212);
    final normalColor = const Color(0xFF9B978F);
    final color = selected ? selectedColor : normalColor;

    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
