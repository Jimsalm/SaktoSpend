import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/data/repositories/budget_repository_local.dart';
import 'package:budget_tracker/data/repositories/session_cart_repository_local.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/usecases.dart';
import 'package:budget_tracker/features/shopping_session/domain/repositories/session_cart_repository.dart';
import 'package:budget_tracker/features/shopping_session/domain/usecases/usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryLocal(database: ref.watch(appDatabaseProvider));
});

final sessionCartRepositoryProvider = Provider<SessionCartRepository>((ref) {
  return SessionCartRepositoryLocal(database: ref.watch(appDatabaseProvider));
});

final getBudgetsUseCaseProvider = Provider<GetBudgetsUseCase>((ref) {
  return GetBudgetsUseCase(ref.watch(budgetRepositoryProvider));
});

final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final getSessionCartItemsUseCaseProvider = Provider<GetSessionCartItemsUseCase>(
  (ref) {
    return GetSessionCartItemsUseCase(ref.watch(sessionCartRepositoryProvider));
  },
);

final addSessionCartItemUseCaseProvider = Provider<AddSessionCartItemUseCase>((
  ref,
) {
  return AddSessionCartItemUseCase(ref.watch(sessionCartRepositoryProvider));
});

final replaceSessionCartItemsUseCaseProvider =
    Provider<ReplaceSessionCartItemsUseCase>((ref) {
      return ReplaceSessionCartItemsUseCase(
        ref.watch(sessionCartRepositoryProvider),
      );
    });

final getSessionCartTotalsUseCaseProvider =
    Provider<GetSessionCartTotalsUseCase>((ref) {
      return GetSessionCartTotalsUseCase(
        ref.watch(sessionCartRepositoryProvider),
      );
    });

final sessionCartTotalsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(getSessionCartTotalsUseCaseProvider).call();
});

final budgetListProvider =
    AsyncNotifierProvider<BudgetListNotifier, List<Budget>>(
      BudgetListNotifier.new,
    );

class BudgetListNotifier extends AsyncNotifier<List<Budget>> {
  late final GetBudgetsUseCase _getBudgetsUseCase;
  late final CreateBudgetUseCase _createBudgetUseCase;
  late final UpdateBudgetUseCase _updateBudgetUseCase;
  late final DeleteBudgetUseCase _deleteBudgetUseCase;

  @override
  Future<List<Budget>> build() async {
    _getBudgetsUseCase = ref.watch(getBudgetsUseCaseProvider);
    _createBudgetUseCase = ref.watch(createBudgetUseCaseProvider);
    _updateBudgetUseCase = ref.watch(updateBudgetUseCaseProvider);
    _deleteBudgetUseCase = ref.watch(deleteBudgetUseCaseProvider);
    return _getBudgetsUseCase.call();
  }

  Future<void> addBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _createBudgetUseCase.call(budget);
      return _getBudgetsUseCase.call();
    });
  }

  Future<void> updateBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _updateBudgetUseCase.call(budget);
      return _getBudgetsUseCase.call();
    });
  }

  Future<void> deleteBudget(String budgetId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _deleteBudgetUseCase.call(budgetId);
      return _getBudgetsUseCase.call();
    });
  }
}
