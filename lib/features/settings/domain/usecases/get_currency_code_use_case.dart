import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';

class GetCurrencyCodeUseCase {
  const GetCurrencyCodeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<String> call() {
    return _repository.getCurrencyCode();
  }
}
