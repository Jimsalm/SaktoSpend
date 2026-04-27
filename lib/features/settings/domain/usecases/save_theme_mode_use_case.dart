import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class SaveThemeModeUseCase {
  const SaveThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String themeMode) {
    return _repository.saveThemeMode(themeMode);
  }
}
