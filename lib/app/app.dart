import 'package:budget_tracker/app/router/app_router.dart';
import 'package:budget_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppHomeScreen(),
    );
  }
}
