import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class GetPrimaryWarningLevelUseCase {
  const GetPrimaryWarningLevelUseCase(this._repository);

  final SettingsRepository _repository;

  Future<double> call() {
    return _repository.getPrimaryWarningLevel();
  }
}
