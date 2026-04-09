import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';

class GetPrimaryWarningLevelUseCase {
  const GetPrimaryWarningLevelUseCase(this._repository);

  final SettingsRepository _repository;

  Future<double> call() {
    return _repository.getPrimaryWarningLevel();
  }
}
