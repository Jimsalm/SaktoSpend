import 'package:budget_tracker/domain/entities/budget_health.dart';
import 'package:budget_tracker/domain/entities/budget_projection.dart';

class BudgetCalculator {
  const BudgetCalculator._();

  static double remainingBudget({
    required double budgetAmount,
    required double runningTotal,
  }) {
    _validateMoneyInput(
      budgetAmount: budgetAmount,
      runningTotal: runningTotal,
    );
    return budgetAmount - runningTotal;
  }

  static double projectedTotal({
    required double runningTotal,
    required double newItemTotal,
  }) {
    _validateNonNegative(name: 'runningTotal', value: runningTotal);
    _validateNonNegative(name: 'newItemTotal', value: newItemTotal);
    return runningTotal + newItemTotal;
  }

  static double projectedRemaining({
    required double budgetAmount,
    required double runningTotal,
    required double newItemTotal,
  }) {
    _validateNonNegative(name: 'budgetAmount', value: budgetAmount);
    final total = projectedTotal(
      runningTotal: runningTotal,
      newItemTotal: newItemTotal,
    );
    return budgetAmount - total;
  }

  static double warningThresholdAmount({
    required double budgetAmount,
    required double warningPercent,
  }) {
    _validateNonNegative(name: 'budgetAmount', value: budgetAmount);
    _validateWarningPercent(warningPercent);
    return budgetAmount * (warningPercent / 100);
  }

  static BudgetHealth healthFromSpent({
    required double budgetAmount,
    required double spentAmount,
    required double warningPercent,
  }) {
    _validateNonNegative(name: 'budgetAmount', value: budgetAmount);
    _validateNonNegative(name: 'spentAmount', value: spentAmount);
    _validateWarningPercent(warningPercent);

    if (spentAmount >= budgetAmount) {
      return BudgetHealth.exceeded;
    }

    final threshold = warningThresholdAmount(
      budgetAmount: budgetAmount,
      warningPercent: warningPercent,
    );

    if (spentAmount >= threshold) {
      return BudgetHealth.warning;
    }

    return BudgetHealth.safe;
  }

  static BudgetProjection projectAddItem({
    required double budgetAmount,
    required double runningTotal,
    required double newItemTotal,
    required double warningPercent,
  }) {
    _validateNonNegative(name: 'budgetAmount', value: budgetAmount);
    _validateNonNegative(name: 'runningTotal', value: runningTotal);
    _validateNonNegative(name: 'newItemTotal', value: newItemTotal);
    _validateWarningPercent(warningPercent);

    final threshold = warningThresholdAmount(
      budgetAmount: budgetAmount,
      warningPercent: warningPercent,
    );

    final total = projectedTotal(
      runningTotal: runningTotal,
      newItemTotal: newItemTotal,
    );

    return BudgetProjection(
      projectedTotal: total,
      projectedRemaining: budgetAmount - total,
      warningThresholdAmount: threshold,
      health: healthFromSpent(
        budgetAmount: budgetAmount,
        spentAmount: total,
        warningPercent: warningPercent,
      ),
      exceedsBudget: total >= budgetAmount,
      crossesWarningThreshold: runningTotal < threshold && total >= threshold,
    );
  }

  static void _validateMoneyInput({
    required double budgetAmount,
    required double runningTotal,
  }) {
    _validateNonNegative(name: 'budgetAmount', value: budgetAmount);
    _validateNonNegative(name: 'runningTotal', value: runningTotal);
  }

  static void _validateNonNegative({
    required String name,
    required double value,
  }) {
    if (value < 0) {
      throw ArgumentError.value(value, name, '$name must be non-negative.');
    }
  }

  static void _validateWarningPercent(double warningPercent) {
    if (warningPercent < 0 || warningPercent > 100) {
      throw ArgumentError.value(
        warningPercent,
        'warningPercent',
        'warningPercent must be between 0 and 100.',
      );
    }
  }
}
