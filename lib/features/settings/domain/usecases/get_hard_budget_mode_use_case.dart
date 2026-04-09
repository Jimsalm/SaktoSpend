import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class GetHardBudgetModeUseCase {
  const GetHardBudgetModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<bool> call() {
    return _repository.getHardBudgetMode();
  }
}
