import 'package:budget_tracker/domain/entities/budget_health.dart';

class BudgetProjection {
  const BudgetProjection({
    required this.projectedTotal,
    required this.projectedRemaining,
    required this.warningThresholdAmount,
    required this.health,
    required this.exceedsBudget,
    required this.crossesWarningThreshold,
  });

  final double projectedTotal;
  final double projectedRemaining;
  final double warningThresholdAmount;
  final BudgetHealth health;
  final bool exceedsBudget;
  final bool crossesWarningThreshold;
}
