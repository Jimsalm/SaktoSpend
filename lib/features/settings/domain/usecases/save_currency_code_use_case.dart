import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class SaveCurrencyCodeUseCase {
  const SaveCurrencyCodeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String currencyCode) {
    return _repository.saveCurrencyCode(currencyCode);
  }
}
