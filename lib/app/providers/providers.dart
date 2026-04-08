import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/data/repositories/budget_repository_local.dart';
import 'package:budget_tracker/data/repositories/history_repository_local.dart';
import 'package:budget_tracker/data/repositories/session_cart_repository_local.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/usecases.dart';
import 'package:budget_tracker/features/history/domain/entities/history_overview.dart';
import 'package:budget_tracker/features/history/domain/repositories/history_repository.dart';
import 'package:budget_tracker/features/history/domain/usecases/usecases.dart';
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

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryLocal(database: ref.watch(appDatabaseProvider));
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

final getHistoryOverviewUseCaseProvider = Provider<GetHistoryOverviewUseCase>((
  ref,
) {
  return GetHistoryOverviewUseCase(ref.watch(historyRepositoryProvider));
});

final sessionCartTotalsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(getSessionCartTotalsUseCaseProvider).call();
});

final historyOverviewProvider = FutureProvider<HistoryOverview>((ref) async {
  return ref.watch(getHistoryOverviewUseCaseProvider).call();
});

final budgetListProvider =
    AsyncNotifierProvider<BudgetListNotifier, List<Budget>>(
      BudgetListNotifier.new,
    );

class BudgetListNotifier extends AsyncNotifier<List<Budget>> {
  GetBudgetsUseCase get _getBudgetsUseCase =>
      ref.read(getBudgetsUseCaseProvider);
  CreateBudgetUseCase get _createBudgetUseCase =>
      ref.read(createBudgetUseCaseProvider);
  UpdateBudgetUseCase get _updateBudgetUseCase =>
      ref.read(updateBudgetUseCaseProvider);
  DeleteBudgetUseCase get _deleteBudgetUseCase =>
      ref.read(deleteBudgetUseCaseProvider);

  @override
  Future<List<Budget>> build() async {
    return ref.watch(getBudgetsUseCaseProvider).call();
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
