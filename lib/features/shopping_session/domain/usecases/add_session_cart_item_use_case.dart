import 'package:budget_tracker/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:budget_tracker/features/shopping_session/domain/repositories/session_cart_repository.dart';

class AddSessionCartItemUseCase {
  const AddSessionCartItemUseCase(this._repository);

  final SessionCartRepository _repository;

  Future<void> call({required String budgetId, required SessionCartItem item}) {
    return _repository.addItem(budgetId: budgetId, item: item);
  }
}
