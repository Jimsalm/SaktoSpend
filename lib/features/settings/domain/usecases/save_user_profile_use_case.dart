import 'package:budget_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';

class SaveUserProfileUseCase {
  const SaveUserProfileUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(UserProfile profile) {
    return _repository.saveUserProfile(profile);
  }
}
