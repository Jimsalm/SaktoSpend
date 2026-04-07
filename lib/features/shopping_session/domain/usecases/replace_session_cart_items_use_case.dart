import 'package:budget_tracker/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:budget_tracker/features/shopping_session/domain/repositories/session_cart_repository.dart';

class ReplaceSessionCartItemsUseCase {
  const ReplaceSessionCartItemsUseCase(this._repository);

  final SessionCartRepository _repository;

  Future<void> call({
    required String budgetId,
    required List<SessionCartItem> items,
  }) {
    return _repository.replaceItemsForBudget(budgetId: budgetId, items: items);
  }
}
