import 'package:SaktoSpend/data/db/app_database.dart';
import 'package:SaktoSpend/data/models/user_profile_model.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:SaktoSpend/features/settings/domain/entities/user_profile.dart';
import 'package:SaktoSpend/features/settings/domain/repositories/settings_repository.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepositoryLocal implements SettingsRepository {
  SettingsRepositoryLocal({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  static const _defaultUserId = 'local_user';
  static const _defaultName = 'User';
  static const _defaultEmail = 'user@example.com';
  static const _currencyCodeKey = 'currency_code';
  static const _hardBudgetModeKey = 'hard_budget_mode';
  static const _spendingThresholdAlertsKey = 'spending_threshold_alerts';
  static const _primaryWarningLevelKey = 'primary_warning_level';
  static const _ocrScannerEnabledKey = 'ocr_scanner_enabled';

  @override
  Future<UserProfile> getUserProfile() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.userProfileTable,
      orderBy: 'datetime(updated_at) DESC, id DESC',
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return UserProfileModel.fromMap(rows.first).toDomain();
    }

    final now = DateTime.now();
    final defaultProfile = UserProfileModel(
      id: _defaultUserId,
      name: _defaultName,
      email: _defaultEmail,
      imageUrl: '',
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      AppDatabase.userProfileTable,
      defaultProfile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return defaultProfile.toDomain();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await _database.instance;
    final existing = await db.query(
      AppDatabase.userProfileTable,
      columns: const ['created_at'],
      where: 'id = ?',
      whereArgs: [
        profile.id.trim().isEmpty ? _defaultUserId : profile.id.trim(),
      ],
      limit: 1,
    );

    final now = DateTime.now();
    final createdAt = existing.isNotEmpty
        ? DateTime.tryParse((existing.first['created_at'] as String?) ?? '')
        : null;

    final normalized = UserProfileModel(
      id: profile.id.trim().isEmpty ? _defaultUserId : profile.id.trim(),
      name: profile.name.trim().isEmpty ? _defaultName : profile.name.trim(),
      email: profile.email.trim().isEmpty
          ? _defaultEmail
          : profile.email.trim(),
      imageUrl: profile.imageUrl.trim(),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );

    await db.insert(
      AppDatabase.userProfileTable,
      normalized.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<String> getCurrencyCode() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.appSettingsTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [_currencyCodeKey],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      final raw = rows.first['value'] as String?;
      final normalized = MoneyUtils.normalizeCurrencyCode(raw);
      if (raw != normalized) {
        await db.insert(
          AppDatabase.appSettingsTable,
          {'key': _currencyCodeKey, 'value': normalized},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return normalized;
    }

    final defaultCode = MoneyUtils.defaultCurrencyCode;
    await db.insert(AppDatabase.appSettingsTable, {
      'key': _currencyCodeKey,
      'value': defaultCode,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return defaultCode;
  }

  @override
  Future<void> saveCurrencyCode(String currencyCode) async {
    final db = await _database.instance;
    await db.insert(AppDatabase.appSettingsTable, {
      'key': _currencyCodeKey,
      'value': MoneyUtils.normalizeCurrencyCode(currencyCode),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<bool> getHardBudgetMode() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.appSettingsTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [_hardBudgetModeKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert(AppDatabase.appSettingsTable, {
        'key': _hardBudgetModeKey,
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    }

    final raw = (rows.first['value'] as String?) ?? '';
    return raw == '1' || raw.toLowerCase() == 'true';
  }

  @override
  Future<void> saveHardBudgetMode(bool enabled) async {
    final db = await _database.instance;
    await db.insert(AppDatabase.appSettingsTable, {
      'key': _hardBudgetModeKey,
      'value': enabled ? '1' : '0',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<bool> getSpendingThresholdAlertsEnabled() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.appSettingsTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [_spendingThresholdAlertsKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert(AppDatabase.appSettingsTable, {
        'key': _spendingThresholdAlertsKey,
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    }

    final raw = (rows.first['value'] as String?) ?? '';
    return raw == '1' || raw.toLowerCase() == 'true';
  }

  @override
  Future<void> saveSpendingThresholdAlertsEnabled(bool enabled) async {
    final db = await _database.instance;
    await db.insert(AppDatabase.appSettingsTable, {
      'key': _spendingThresholdAlertsKey,
      'value': enabled ? '1' : '0',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<double> getPrimaryWarningLevel() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.appSettingsTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [_primaryWarningLevelKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      const defaultLevel = 80.0;
      await db.insert(AppDatabase.appSettingsTable, {
        'key': _primaryWarningLevelKey,
        'value': defaultLevel.toStringAsFixed(1),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return defaultLevel;
    }

    final raw = (rows.first['value'] as String?) ?? '';
    return _normalizeWarningLevel(double.tryParse(raw) ?? 80.0);
  }

  @override
  Future<void> savePrimaryWarningLevel(double level) async {
    final db = await _database.instance;
    final normalized = _normalizeWarningLevel(level);
    await db.insert(AppDatabase.appSettingsTable, {
      'key': _primaryWarningLevelKey,
      'value': normalized.toStringAsFixed(1),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<bool> getOcrScannerEnabled() async {
    final db = await _database.instance;
    final rows = await db.query(
      AppDatabase.appSettingsTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [_ocrScannerEnabledKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert(AppDatabase.appSettingsTable, {
        'key': _ocrScannerEnabledKey,
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    }

    final raw = (rows.first['value'] as String?) ?? '';
    return raw == '1' || raw.toLowerCase() == 'true';
  }

  @override
  Future<void> saveOcrScannerEnabled(bool enabled) async {
    final db = await _database.instance;
    await db.insert(AppDatabase.appSettingsTable, {
      'key': _ocrScannerEnabledKey,
      'value': enabled ? '1' : '0',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  double _normalizeWarningLevel(double level) {
    return level.clamp(50.0, 95.0).toDouble();
  }
}
