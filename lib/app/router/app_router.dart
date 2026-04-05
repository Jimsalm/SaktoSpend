import 'package:budget_tracker/features/budgets/presentation/screens/budgets_tab_screen.dart';
import 'package:budget_tracker/features/dashboard/presentation/screens/home_overview_screen.dart';
import 'package:budget_tracker/features/history/presentation/screens/history_screen.dart';
import 'package:budget_tracker/features/scanner/presentation/screens/scan_review_screen.dart';
import 'package:budget_tracker/features/shopping_session/presentation/screens/active_session_screen.dart';
import 'package:flutter/material.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  int _tabIndex = 0;
  _BudgetsFlow _budgetsFlow = _BudgetsFlow.overview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: _fabLocation(),
      bottomNavigationBar: _MainBottomNav(
        currentIndex: _tabIndex,
        onTap: _onTabTap,
      ),
    );
  }

  Widget _buildBody() {
    if (_tabIndex == 0) {
      return const HomeOverviewScreen();
    }

    if (_tabIndex == 1) {
      switch (_budgetsFlow) {
        case _BudgetsFlow.overview:
          return BudgetsTabScreen(
            onOpenActiveSession: () {
              setState(() => _budgetsFlow = _BudgetsFlow.activeSession);
            },
          );
        case _BudgetsFlow.activeSession:
          return ActiveSessionScreen(
            onOpenScanner: () {
              setState(() => _budgetsFlow = _BudgetsFlow.scanReview);
            },
          );
        case _BudgetsFlow.scanReview:
          return ScanReviewScreen(
            onBack: () {
              setState(() => _budgetsFlow = _BudgetsFlow.activeSession);
            },
            onAddToCart: () {
              setState(() => _budgetsFlow = _BudgetsFlow.activeSession);
            },
          );
      }
    }

    if (_tabIndex == 2) {
      return const HistoryScreen();
    }

    if (_tabIndex == 3) {
      return const _SimpleTab(title: 'Settings', subtitle: 'Settings controls will appear here.');
    }

    return const _SimpleTab(title: 'Settings', subtitle: 'Settings controls will appear here.');
  }

  Widget? _buildFab() {
    if (_tabIndex == 0) {
      return _DarkFab(
        onTap: () {},
        size: 56,
      );
    }

    if (_tabIndex == 1 && _budgetsFlow == _BudgetsFlow.overview) {
      return _DarkFab(
        onTap: () {},
        size: 54,
      );
    }

    return null;
  }

  FloatingActionButtonLocation _fabLocation() {
    return FloatingActionButtonLocation.endFloat;
  }

  void _onTabTap(int index) {
    setState(() {
      _tabIndex = index;
      if (index != 1) {
        _budgetsFlow = _BudgetsFlow.overview;
      }
    });
  }
}

enum _BudgetsFlow {
  overview,
  activeSession,
  scanReview,
}

class _DarkFab extends StatelessWidget {
  const _DarkFab({
    required this.onTap,
    required this.size,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

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
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Budgets',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.history,
            label: 'History',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF121212);
    final normalColor = const Color(0xFF9B978F);
    final color = selected ? selectedColor : normalColor;

    return SizedBox(
      width: 64,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
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
      ),
    );
  }
}

class _SimpleTab extends StatelessWidget {
  const _SimpleTab({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 52),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
