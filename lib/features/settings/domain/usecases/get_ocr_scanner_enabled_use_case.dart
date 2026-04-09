import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';

class GetOcrScannerEnabledUseCase {
  const GetOcrScannerEnabledUseCase(this._repository);

  final SettingsRepository _repository;

  Future<bool> call() {
    return _repository.getOcrScannerEnabled();
  }
}
