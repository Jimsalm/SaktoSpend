import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';

class GetSpendingThresholdAlertsEnabledUseCase {
  const GetSpendingThresholdAlertsEnabledUseCase(this._repository);

  final SettingsRepository _repository;

  Future<bool> call() {
    return _repository.getSpendingThresholdAlertsEnabled();
  }
}
