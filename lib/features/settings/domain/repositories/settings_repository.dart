import 'package:budget_tracker/features/settings/domain/entities/user_profile.dart';

abstract class SettingsRepository {
  Future<UserProfile> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);
  Future<String> getCurrencyCode();
  Future<void> saveCurrencyCode(String currencyCode);
  Future<bool> getHardBudgetMode();
  Future<void> saveHardBudgetMode(bool enabled);
  Future<bool> getSpendingThresholdAlertsEnabled();
  Future<void> saveSpendingThresholdAlertsEnabled(bool enabled);
  Future<double> getPrimaryWarningLevel();
  Future<void> savePrimaryWarningLevel(double level);
  Future<bool> getOcrScannerEnabled();
  Future<void> saveOcrScannerEnabled(bool enabled);
}
