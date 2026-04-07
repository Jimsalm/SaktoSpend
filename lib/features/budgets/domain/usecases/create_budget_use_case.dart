import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/repositories/budget_repository.dart';

class CreateBudgetUseCase {
  const CreateBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<void> call(Budget budget) {
    return _repository.createBudget(budget);
  }
}
