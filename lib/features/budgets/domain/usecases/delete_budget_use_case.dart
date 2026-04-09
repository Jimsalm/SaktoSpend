import 'package:SaktoSpend/features/budgets/domain/repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  const DeleteBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<void> call(String budgetId) {
    return _repository.deleteBudget(budgetId);
  }
}
