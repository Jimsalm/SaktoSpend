import 'package:budget_tracker/features/shopping_session/domain/repositories/session_cart_repository.dart';

class GetSessionCartTotalsUseCase {
  const GetSessionCartTotalsUseCase(this._repository);

  final SessionCartRepository _repository;

  Future<Map<String, int>> call() {
    return _repository.getTotalsByBudget();
  }
}
