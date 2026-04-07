import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/repositories/budget_repository.dart';

class GetBudgetsUseCase {
  const GetBudgetsUseCase(this._repository);

  final BudgetRepository _repository;

  Future<List<Budget>> call() {
    return _repository.getBudgets();
  }
}
