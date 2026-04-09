import 'package:SaktoSpend/features/shopping_session/domain/entities/session_cart_item.dart';

abstract class SessionCartRepository {
  Future<List<SessionCartItem>> getItemsForBudget(String budgetId);
  Future<Map<String, int>> getTotalsByBudget();
  Future<void> addItem({
    required String budgetId,
    required SessionCartItem item,
  });
  Future<void> clearForBudget(String budgetId);
  Future<void> replaceItemsForBudget({
    required String budgetId,
    required List<SessionCartItem> items,
  });
}
