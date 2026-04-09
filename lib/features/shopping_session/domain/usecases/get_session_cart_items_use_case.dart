import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';
import 'package:SaktoSpend/features/shopping_session/domain/repositories/session_cart_repository.dart';

class GetSessionCartItemsUseCase {
  const GetSessionCartItemsUseCase(this._repository);

  final SessionCartRepository _repository;

  Future<List<SessionCartItem>> call(String budgetId) {
    return _repository.getItemsForBudget(budgetId);
  }
}
