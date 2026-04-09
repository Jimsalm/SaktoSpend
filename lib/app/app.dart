import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/app/router/app_router.dart';
import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaktoSpendApp extends ConsumerWidget {
  const SaktoSpendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appCurrencyCodeProvider);
    ref.watch(appHardBudgetModeProvider);
    ref.watch(appSpendingThresholdAlertsProvider);
    ref.watch(appPrimaryWarningLevelProvider);
    ref.watch(appOcrScannerEnabledProvider);

    return MaterialApp(
      title: 'Shopping Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppHomeScreen(),
    );
  }
}
