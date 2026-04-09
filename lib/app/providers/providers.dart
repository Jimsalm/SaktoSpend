import 'package:budget_tracker/data/db/app_database.dart';
import 'package:budget_tracker/data/repositories/budget_repository_local.dart';
import 'package:budget_tracker/data/repositories/dashboard_repository_local.dart';
import 'package:budget_tracker/data/repositories/history_repository_local.dart';
import 'package:budget_tracker/data/repositories/settings_repository_local.dart';
import 'package:budget_tracker/data/repositories/session_cart_repository_local.dart';
import 'package:budget_tracker/core/utils/utils.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/usecases.dart';
import 'package:budget_tracker/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:budget_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:budget_tracker/features/dashboard/domain/usecases/usecases.dart';
import 'package:budget_tracker/features/history/domain/entities/history_overview.dart';
import 'package:budget_tracker/features/history/domain/repositories/history_repository.dart';
import 'package:budget_tracker/features/history/domain/usecases/usecases.dart';
import 'package:budget_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:budget_tracker/features/settings/domain/usecases/usecases.dart';
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

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryLocal(database: ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryLocal(database: ref.watch(appDatabaseProvider));
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

final getDashboardOverviewUseCaseProvider =
    Provider<GetDashboardOverviewUseCase>((ref) {
      return GetDashboardOverviewUseCase(ref.watch(dashboardRepositoryProvider));
    });

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(settingsRepositoryProvider));
});

final saveUserProfileUseCaseProvider = Provider<SaveUserProfileUseCase>((ref) {
  return SaveUserProfileUseCase(ref.watch(settingsRepositoryProvider));
});

final getCurrencyCodeUseCaseProvider = Provider<GetCurrencyCodeUseCase>((ref) {
  return GetCurrencyCodeUseCase(ref.watch(settingsRepositoryProvider));
});

final saveCurrencyCodeUseCaseProvider = Provider<SaveCurrencyCodeUseCase>((ref) {
  return SaveCurrencyCodeUseCase(ref.watch(settingsRepositoryProvider));
});

final getHardBudgetModeUseCaseProvider = Provider<GetHardBudgetModeUseCase>((ref) {
  return GetHardBudgetModeUseCase(ref.watch(settingsRepositoryProvider));
});

final saveHardBudgetModeUseCaseProvider =
    Provider<SaveHardBudgetModeUseCase>((ref) {
      return SaveHardBudgetModeUseCase(ref.watch(settingsRepositoryProvider));
    });

final getSpendingThresholdAlertsEnabledUseCaseProvider =
    Provider<GetSpendingThresholdAlertsEnabledUseCase>((ref) {
      return GetSpendingThresholdAlertsEnabledUseCase(
        ref.watch(settingsRepositoryProvider),
      );
    });

final saveSpendingThresholdAlertsEnabledUseCaseProvider =
    Provider<SaveSpendingThresholdAlertsEnabledUseCase>((ref) {
      return SaveSpendingThresholdAlertsEnabledUseCase(
        ref.watch(settingsRepositoryProvider),
      );
    });

final getPrimaryWarningLevelUseCaseProvider =
    Provider<GetPrimaryWarningLevelUseCase>((ref) {
      return GetPrimaryWarningLevelUseCase(ref.watch(settingsRepositoryProvider));
    });

final savePrimaryWarningLevelUseCaseProvider =
    Provider<SavePrimaryWarningLevelUseCase>((ref) {
      return SavePrimaryWarningLevelUseCase(
        ref.watch(settingsRepositoryProvider),
      );
    });

final getOcrScannerEnabledUseCaseProvider =
    Provider<GetOcrScannerEnabledUseCase>((ref) {
      return GetOcrScannerEnabledUseCase(ref.watch(settingsRepositoryProvider));
    });

final saveOcrScannerEnabledUseCaseProvider =
    Provider<SaveOcrScannerEnabledUseCase>((ref) {
      return SaveOcrScannerEnabledUseCase(ref.watch(settingsRepositoryProvider));
    });

final sessionCartTotalsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(getSessionCartTotalsUseCaseProvider).call();
});

final historyOverviewProvider = FutureProvider<HistoryOverview>((ref) async {
  return ref.watch(getHistoryOverviewUseCaseProvider).call();
});

final dashboardOverviewProvider = FutureProvider<DashboardOverview>((ref) async {
  return ref.watch(getDashboardOverviewUseCaseProvider).call();
});

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
      UserProfileNotifier.new,
    );

final appCurrencyCodeProvider =
    AsyncNotifierProvider<AppCurrencyCodeNotifier, String>(
      AppCurrencyCodeNotifier.new,
    );

final appHardBudgetModeProvider =
    AsyncNotifierProvider<AppHardBudgetModeNotifier, bool>(
      AppHardBudgetModeNotifier.new,
    );

final appSpendingThresholdAlertsProvider =
    AsyncNotifierProvider<AppSpendingThresholdAlertsNotifier, bool>(
      AppSpendingThresholdAlertsNotifier.new,
    );

final appPrimaryWarningLevelProvider =
    AsyncNotifierProvider<AppPrimaryWarningLevelNotifier, double>(
      AppPrimaryWarningLevelNotifier.new,
    );

final appOcrScannerEnabledProvider =
    AsyncNotifierProvider<AppOcrScannerEnabledNotifier, bool>(
      AppOcrScannerEnabledNotifier.new,
    );

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

class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  GetUserProfileUseCase get _getUserProfileUseCase =>
      ref.read(getUserProfileUseCaseProvider);
  SaveUserProfileUseCase get _saveUserProfileUseCase =>
      ref.read(saveUserProfileUseCaseProvider);

  @override
  Future<UserProfile> build() async {
    return _getUserProfileUseCase.call();
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String imageUrl,
  }) async {
    final current = state.valueOrNull ?? await _getUserProfileUseCase.call();
    final updated = UserProfile(
      id: current.id,
      name: name,
      email: email,
      imageUrl: imageUrl,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _saveUserProfileUseCase.call(updated);
      return _getUserProfileUseCase.call();
    });
  }
}

class AppCurrencyCodeNotifier extends AsyncNotifier<String> {
  GetCurrencyCodeUseCase get _getCurrencyCodeUseCase =>
      ref.read(getCurrencyCodeUseCaseProvider);
  SaveCurrencyCodeUseCase get _saveCurrencyCodeUseCase =>
      ref.read(saveCurrencyCodeUseCaseProvider);

  @override
  Future<String> build() async {
    final code = MoneyUtils.normalizeCurrencyCode(
      await _getCurrencyCodeUseCase.call(),
    );
    MoneyUtils.setCurrencyCode(code);
    return code;
  }

  Future<void> saveCurrencyCode(String currencyCode) async {
    final normalized = MoneyUtils.normalizeCurrencyCode(currencyCode);
    final previous = state.valueOrNull ?? MoneyUtils.defaultCurrencyCode;

    state = AsyncValue.data(normalized);
    MoneyUtils.setCurrencyCode(normalized);

    try {
      await _saveCurrencyCodeUseCase.call(normalized);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      MoneyUtils.setCurrencyCode(previous);
      rethrow;
    }
  }
}

class AppHardBudgetModeNotifier extends AsyncNotifier<bool> {
  GetHardBudgetModeUseCase get _getHardBudgetModeUseCase =>
      ref.read(getHardBudgetModeUseCaseProvider);
  SaveHardBudgetModeUseCase get _saveHardBudgetModeUseCase =>
      ref.read(saveHardBudgetModeUseCaseProvider);

  @override
  Future<bool> build() async {
    return _getHardBudgetModeUseCase.call();
  }

  Future<void> saveHardBudgetMode(bool enabled) async {
    final previous = state.valueOrNull ?? true;
    state = AsyncValue.data(enabled);
    try {
      await _saveHardBudgetModeUseCase.call(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      state = AsyncValue.data(previous);
      rethrow;
    }
  }
}

class AppSpendingThresholdAlertsNotifier extends AsyncNotifier<bool> {
  GetSpendingThresholdAlertsEnabledUseCase
      get _getSpendingThresholdAlertsUseCase =>
          ref.read(getSpendingThresholdAlertsEnabledUseCaseProvider);
  SaveSpendingThresholdAlertsEnabledUseCase
      get _saveSpendingThresholdAlertsUseCase =>
          ref.read(saveSpendingThresholdAlertsEnabledUseCaseProvider);

  @override
  Future<bool> build() async {
    return _getSpendingThresholdAlertsUseCase.call();
  }

  Future<void> saveEnabled(bool enabled) async {
    final previous = state.valueOrNull ?? true;
    state = AsyncValue.data(enabled);
    try {
      await _saveSpendingThresholdAlertsUseCase.call(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      state = AsyncValue.data(previous);
      rethrow;
    }
  }
}

class AppPrimaryWarningLevelNotifier extends AsyncNotifier<double> {
  GetPrimaryWarningLevelUseCase get _getPrimaryWarningLevelUseCase =>
      ref.read(getPrimaryWarningLevelUseCaseProvider);
  SavePrimaryWarningLevelUseCase get _savePrimaryWarningLevelUseCase =>
      ref.read(savePrimaryWarningLevelUseCaseProvider);

  @override
  Future<double> build() async {
    return _normalize(await _getPrimaryWarningLevelUseCase.call());
  }

  void setLocal(double level) {
    state = AsyncValue.data(_normalize(level));
  }

  Future<void> saveLevel(double level) async {
    final normalized = _normalize(level);
    final previous = state.valueOrNull ?? 80.0;
    state = AsyncValue.data(normalized);
    try {
      await _savePrimaryWarningLevelUseCase.call(normalized);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      state = AsyncValue.data(previous);
      rethrow;
    }
  }

  double _normalize(double level) {
    return level.clamp(50.0, 95.0).toDouble();
  }
}

class AppOcrScannerEnabledNotifier extends AsyncNotifier<bool> {
  GetOcrScannerEnabledUseCase get _getOcrScannerEnabledUseCase =>
      ref.read(getOcrScannerEnabledUseCaseProvider);
  SaveOcrScannerEnabledUseCase get _saveOcrScannerEnabledUseCase =>
      ref.read(saveOcrScannerEnabledUseCaseProvider);

  @override
  Future<bool> build() async {
    return _getOcrScannerEnabledUseCase.call();
  }

  Future<void> saveEnabled(bool enabled) async {
    final previous = state.valueOrNull ?? true;
    state = AsyncValue.data(enabled);
    try {
      await _saveOcrScannerEnabledUseCase.call(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      state = AsyncValue.data(previous);
      rethrow;
    }
  }
}
