import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class SaveOcrScannerEnabledUseCase {
  const SaveOcrScannerEnabledUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(bool enabled) {
    return _repository.saveOcrScannerEnabled(enabled);
  }
}
