import 'package:SaktoSpend/features/budgets/domain/entities/budget_health.dart';
import 'package:SaktoSpend/features/budgets/domain/usecases/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetCalculator', () {
    test('remainingBudget returns budget minus running total', () {
      final result = BudgetCalculator.remainingBudget(
        budgetAmount: 120,
        runningTotal: 45,
      );

      expect(result, 75);
    });

    test('projectedRemaining returns budget minus projected total', () {
      final result = BudgetCalculator.projectedRemaining(
        budgetAmount: 200,
        runningTotal: 120,
        newItemTotal: 20,
      );

      expect(result, 60);
    });

    test('healthFromSpent is safe when spent is below warning threshold', () {
      final result = BudgetCalculator.healthFromSpent(
        budgetAmount: 100,
        spentAmount: 60,
        warningPercent: 80,
      );

      expect(result, BudgetHealth.safe);
    });

    test('healthFromSpent is warning when spent reaches threshold', () {
      final result = BudgetCalculator.healthFromSpent(
        budgetAmount: 100,
        spentAmount: 80,
        warningPercent: 80,
      );

      expect(result, BudgetHealth.warning);
    });

    test('healthFromSpent is exceeded when spent reaches budget', () {
      final result = BudgetCalculator.healthFromSpent(
        budgetAmount: 100,
        spentAmount: 100,
        warningPercent: 80,
      );

      expect(result, BudgetHealth.exceeded);
    });

    test('projectAddItem reports threshold crossing and no budget exceed', () {
      final result = BudgetCalculator.projectAddItem(
        budgetAmount: 100,
        runningTotal: 70,
        newItemTotal: 10,
        warningPercent: 80,
      );

      expect(result.projectedTotal, 80);
      expect(result.projectedRemaining, 20);
      expect(result.crossesWarningThreshold, isTrue);
      expect(result.exceedsBudget, isFalse);
      expect(result.health, BudgetHealth.warning);
    });

    test('projectAddItem reports budget exceed', () {
      final result = BudgetCalculator.projectAddItem(
        budgetAmount: 100,
        runningTotal: 95,
        newItemTotal: 15,
        warningPercent: 80,
      );

      expect(result.projectedTotal, 110);
      expect(result.projectedRemaining, -10);
      expect(result.exceedsBudget, isTrue);
      expect(result.health, BudgetHealth.exceeded);
    });
  });
}
