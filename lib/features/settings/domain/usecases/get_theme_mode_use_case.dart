import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class GetThemeModeUseCase {
  const GetThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<String> call() {
    return _repository.getThemeMode();
  }
}
