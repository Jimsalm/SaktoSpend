import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class SaveHardBudgetModeUseCase {
  const SaveHardBudgetModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(bool enabled) {
    return _repository.saveHardBudgetMode(enabled);
  }
}
