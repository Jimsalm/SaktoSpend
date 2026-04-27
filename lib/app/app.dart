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
    final themeModeAsync = ref.watch(appThemeModeProvider);
    ref.watch(appHardBudgetModeProvider);
    ref.watch(appSpendingThresholdAlertsProvider);
    ref.watch(appPrimaryWarningLevelProvider);
    ref.watch(appOcrScannerEnabledProvider);
    final themeMode = switch (themeModeAsync.valueOrNull ?? 'light') {
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };

    return MaterialApp(
      title: 'Shopping Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const AppHomeScreen(),
    );
  }
}
