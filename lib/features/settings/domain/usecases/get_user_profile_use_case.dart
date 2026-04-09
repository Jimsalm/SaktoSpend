import 'package:budget_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';

class GetUserProfileUseCase {
  const GetUserProfileUseCase(this._repository);

  final SettingsRepository _repository;

  Future<UserProfile> call() {
    return _repository.getUserProfile();
  }
}
