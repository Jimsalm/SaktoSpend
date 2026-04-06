import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/data/repositories/budget_repository_local.dart';
import 'package:budget_tracker/data/repositories/session_cart_repository_local.dart';
import 'package:budget_tracker/domain/entities/budget.dart';
import 'package:budget_tracker/domain/repositories/budget_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryLocal(database: ref.watch(appDatabaseProvider));
});

final sessionCartRepositoryProvider = Provider<SessionCartRepositoryLocal>((ref) {
  return SessionCartRepositoryLocal(database: ref.watch(appDatabaseProvider));
});

final sessionCartTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  return ref.watch(sessionCartRepositoryProvider).getTotalsByBudget();
});

final budgetListProvider =
    AsyncNotifierProvider<BudgetListNotifier, List<Budget>>(
      BudgetListNotifier.new,
    );

class BudgetListNotifier extends AsyncNotifier<List<Budget>> {
  late final BudgetRepository _repository;

  @override
  Future<List<Budget>> build() async {
    _repository = ref.watch(budgetRepositoryProvider);
    return _repository.getBudgets();
  }

  Future<void> addBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.createBudget(budget);
      return _repository.getBudgets();
    });
  }

  Future<void> updateBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateBudget(budget);
      return _repository.getBudgets();
    });
  }

  Future<void> deleteBudget(String budgetId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteBudget(budgetId);
      return _repository.getBudgets();
    });
  }
}
