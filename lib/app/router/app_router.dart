import 'dart:async';

import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/budgets/presentation/screens/budgets_tab_screen.dart';
import 'package:SaktoSpend/features/budgets/domain/entities/budget.dart';
import 'package:SaktoSpend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:SaktoSpend/features/history/presentation/screens/history_screen.dart';
import 'package:SaktoSpend/features/scanner/presentation/screens/scan_review_screen.dart';
import 'package:SaktoSpend/features/settings/presentation/screens/settings_screen.dart';
import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:SaktoSpend/features/shopping_session/presentation/screens/active_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppHomeScreen extends ConsumerStatefulWidget {
  const AppHomeScreen({super.key});

  @override
  ConsumerState<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends ConsumerState<AppHomeScreen> {
  int _tabIndex = 0;
  _BudgetsFlow _budgetsFlow = _BudgetsFlow.overview;
  VoidCallback? _budgetsCreateAction;
  Budget? _selectedBudget;
  bool _scannerManualMode = false;
  final List<SessionCartItem> _sessionCartItems = [];
  String? _pendingThresholdAlertMessage;
  bool _isThresholdAlertFlushScheduled = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_shouldHandleInAppBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleInAppBack();
      },
      child: Scaffold(
        body: _buildBody(),
        floatingActionButton: _buildFab(),
        floatingActionButtonLocation: _fabLocation(),
        bottomNavigationBar: _MainBottomNav(
          currentIndex: _tabIndex,
          onTap: _onTabTap,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_tabIndex == 0) {
      return DashboardScreen(
        onOpenRecentBudget: (budgetId) {
          unawaited(_openBudgetFromDashboard(budgetId));
        },
      );
    }

    if (_tabIndex == 1) {
      switch (_budgetsFlow) {
        case _BudgetsFlow.overview:
          return BudgetsTabScreen(
            onOpenActiveSession: (budget) {
              unawaited(_openActiveSession(budget));
            },
            onCreateActionChanged: (action) {
              _budgetsCreateAction = action;
            },
          );
        case _BudgetsFlow.activeSession:
          _scheduleThresholdAlertFlush();
          return ActiveSessionScreen(
            budget: _selectedBudget,
            hardBudgetModeEnabled: _isHardBudgetModeEnabled,
            ocrScannerEnabled: _isOcrScannerEnabled,
            cartItems: _sessionCartItems,
            onAddManualItem: (item) {
              unawaited(_addItemToSession(item));
            },
            onEditItem: (index, item) {
              unawaited(_editSessionItem(index, item));
            },
            onDeleteItem: (index) {
              unawaited(_deleteSessionItem(index));
            },
            onBack: () {
              setState(() {
                _scannerManualMode = false;
                _budgetsFlow = _BudgetsFlow.overview;
              });
            },
            onOpenScanner: () {
              if (!_isOcrScannerEnabled) {
                AppSnackbars.showError(
                  context,
                  'OCR Scanner is disabled in Settings.',
                );
                return;
              }
              setState(() {
                _scannerManualMode = false;
                _budgetsFlow = _BudgetsFlow.scanReview;
              });
            },
          );
        case _BudgetsFlow.scanReview:
          return ScanReviewScreen(
            budget: _selectedBudget,
            existingCartItems: _sessionCartItems,
            initialManualEntry: _scannerManualMode,
            hardBudgetModeEnabled: _isHardBudgetModeEnabled,
            onBack: () {
              setState(() {
                _scannerManualMode = false;
                _budgetsFlow = _BudgetsFlow.activeSession;
              });
            },
            onAddToCart: (item) {
              unawaited(_addItemToSession(item));
            },
          );
      }
    }

    if (_tabIndex == 2) {
      return const HistoryScreen();
    }

    if (_tabIndex == 3) {
      return const SettingsScreen();
    }

    return const _SimpleTab(
      title: 'Settings',
      subtitle: 'Settings controls will appear here.',
    );
  }

  Widget? _buildFab() {
    if (_tabIndex == 1 && _budgetsFlow == _BudgetsFlow.overview) {
      return _DarkFab(
        onTap: () {
          (_budgetsCreateAction ?? () {})();
        },
        size: 58,
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
    });
  }

  bool get _shouldHandleInAppBack =>
      (_tabIndex == 1 && _budgetsFlow == _BudgetsFlow.scanReview) ||
      (_tabIndex == 1 && _budgetsFlow == _BudgetsFlow.activeSession) ||
      _tabIndex != 0;

  bool get _isHardBudgetModeEnabled =>
      ref.read(appHardBudgetModeProvider).valueOrNull ?? true;
  bool get _isSpendingThresholdAlertsEnabled =>
      ref.read(appSpendingThresholdAlertsProvider).valueOrNull ?? true;
  double get _primaryWarningLevel =>
      ref.read(appPrimaryWarningLevelProvider).valueOrNull ?? 80.0;
  bool get _isOcrScannerEnabled =>
      ref.read(appOcrScannerEnabledProvider).valueOrNull ?? true;

  bool _handleInAppBack() {
    if (_tabIndex == 1 && _budgetsFlow == _BudgetsFlow.scanReview) {
      setState(() {
        _scannerManualMode = false;
        _budgetsFlow = _BudgetsFlow.activeSession;
      });
      return true;
    }

    if (_tabIndex == 1 && _budgetsFlow == _BudgetsFlow.activeSession) {
      setState(() {
        _scannerManualMode = false;
        _selectedBudget = null;
        _sessionCartItems.clear();
        _budgetsFlow = _BudgetsFlow.overview;
      });
      return true;
    }

    if (_tabIndex != 0) {
      setState(() {
        _tabIndex = 0;
      });
      return true;
    }

    return false;
  }

  Future<void> _openActiveSession(Budget budget) async {
    setState(() {
      _selectedBudget = budget;
      _scannerManualMode = false;
      _budgetsFlow = _BudgetsFlow.activeSession;
      _sessionCartItems.clear();
    });

    final persistedItems = await ref
        .read(getSessionCartItemsUseCaseProvider)
        .call(budget.id);
    if (!mounted || _selectedBudget?.id != budget.id) {
      return;
    }

    setState(() {
      _sessionCartItems
        ..clear()
        ..addAll(persistedItems);
    });
  }

  Future<void> _openBudgetFromDashboard(String budgetId) async {
    final budgets = await ref.read(getBudgetsUseCaseProvider).call();
    Budget? targetBudget;
    for (final budget in budgets) {
      if (budget.id == budgetId) {
        targetBudget = budget;
        break;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _tabIndex = 1;
    });

    if (targetBudget == null) {
      return;
    }

    await _openActiveSession(targetBudget);
  }

  Future<void> _addItemToSession(SessionCartItem item) async {
    final budgetId = _selectedBudget?.id;
    if (budgetId == null) {
      return;
    }

    final budgetAmount = _selectedBudget?.amount ?? 0;
    final currentTotal = _sessionCartItems.fold<int>(
      0,
      (sum, existing) => sum + existing.totalPrice,
    );
    final projectedTotal = currentTotal + item.totalPrice;
    if (_isHardBudgetModeEnabled && projectedTotal > budgetAmount) {
      _showHardBudgetBlockedMessage();
      return;
    }
    final thresholdAlertMessage = _buildSpendingThresholdAlertMessage(
      previousSpent: currentTotal,
      nextSpent: projectedTotal,
      budgetAmount: budgetAmount,
    );

    setState(() {
      _sessionCartItems.add(item);
      _scannerManualMode = false;
      _budgetsFlow = _BudgetsFlow.activeSession;
    });
    _showSpendingThresholdAlert(thresholdAlertMessage);

    await ref
        .read(addSessionCartItemUseCaseProvider)
        .call(budgetId: budgetId, item: item);
    ref.invalidate(sessionCartTotalsProvider);
  }

  Future<void> _editSessionItem(int index, SessionCartItem updatedItem) async {
    final budgetId = _selectedBudget?.id;
    if (budgetId == null || index < 0 || index >= _sessionCartItems.length) {
      return;
    }

    final existingItem = _sessionCartItems[index];
    final budgetAmount = _selectedBudget?.amount ?? 0;
    final currentTotal = _sessionCartItems.fold<int>(
      0,
      (sum, existing) => sum + existing.totalPrice,
    );
    final projectedTotal =
        currentTotal - existingItem.totalPrice + updatedItem.totalPrice;
    if (_isHardBudgetModeEnabled && projectedTotal > budgetAmount) {
      _showHardBudgetBlockedMessage();
      return;
    }
    final thresholdAlertMessage = _buildSpendingThresholdAlertMessage(
      previousSpent: currentTotal,
      nextSpent: projectedTotal,
      budgetAmount: budgetAmount,
    );

    setState(() {
      _sessionCartItems[index] = updatedItem;
    });
    _showSpendingThresholdAlert(thresholdAlertMessage);

    await ref
        .read(replaceSessionCartItemsUseCaseProvider)
        .call(budgetId: budgetId, items: _sessionCartItems);
    ref.invalidate(sessionCartTotalsProvider);
  }

  Future<void> _deleteSessionItem(int index) async {
    final budgetId = _selectedBudget?.id;
    if (budgetId == null || index < 0 || index >= _sessionCartItems.length) {
      return;
    }

    setState(() {
      _sessionCartItems.removeAt(index);
    });

    await ref
        .read(replaceSessionCartItemsUseCaseProvider)
        .call(budgetId: budgetId, items: _sessionCartItems);
    ref.invalidate(sessionCartTotalsProvider);
  }

  void _showHardBudgetBlockedMessage() {
    if (!mounted) {
      return;
    }
    AppSnackbars.showError(
      context,
      'Hard Budget Mode is enabled. This entry exceeds the remaining budget.',
    );
  }

  String? _buildSpendingThresholdAlertMessage({
    required int previousSpent,
    required int nextSpent,
    required int budgetAmount,
  }) {
    if (!_isSpendingThresholdAlertsEnabled || budgetAmount <= 0) {
      return null;
    }

    final budgetWarning =
        _selectedBudget?.warningPercent ?? _primaryWarningLevel;
    final warningPercent =
        (budgetWarning <= 0 ? _primaryWarningLevel : budgetWarning)
            .clamp(0.0, 100.0)
            .toDouble();
    final threshold = warningPercent / 100;
    final previousUtilization = (previousSpent / budgetAmount).clamp(0.0, 1.0);
    final nextUtilization = (nextSpent / budgetAmount).clamp(0.0, 1.0);

    if (previousUtilization < threshold && nextUtilization >= threshold) {
      final budgetName = _selectedBudget?.name.trim();
      final label = (budgetName == null || budgetName.isEmpty)
          ? 'Budget'
          : budgetName;
      return '$label reached ${warningPercent.toStringAsFixed(0)}% of total budget.';
    }
    return null;
  }

  void _showSpendingThresholdAlert(String? message) {
    if (message == null || !mounted) {
      return;
    }
    _pendingThresholdAlertMessage = message;
    _scheduleThresholdAlertFlush();
  }

  void _scheduleThresholdAlertFlush() {
    if (_isThresholdAlertFlushScheduled || !mounted) {
      return;
    }
    _isThresholdAlertFlushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isThresholdAlertFlushScheduled = false;
      if (!mounted) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) {
        return;
      }
      _flushPendingThresholdAlert();
    });
  }

  void _flushPendingThresholdAlert() {
    final message = _pendingThresholdAlertMessage;
    if (message == null) {
      return;
    }
    if (_tabIndex != 1 || _budgetsFlow != _BudgetsFlow.activeSession) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    _pendingThresholdAlertMessage = null;
    AppSnackbars.showSuccess(context, message);
  }
}

enum _BudgetsFlow { overview, activeSession, scanReview }

class _DarkFab extends StatelessWidget {
  const _DarkFab({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: tokens.accentStrong,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 10),
                color: tokens.shadowColor,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.add_rounded,
                  color: tokens.textPrimary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        decoration: BoxDecoration(
          color: tokens.surfacePrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: tokens.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Budgets',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final foregroundColor = selected ? tokens.textPrimary : tokens.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? tokens.accentStrong : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? Border.all(color: Colors.white.withValues(alpha: 0.58))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: tokens.shadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: foregroundColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleTab extends StatelessWidget {
  const _SimpleTab({required this.title, required this.subtitle});

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
