import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';

class SavePrimaryWarningLevelUseCase {
  const SavePrimaryWarningLevelUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(double level) {
    return _repository.savePrimaryWarningLevel(level);
  }
}
