import 'dart:io';

import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/theme/app_theme.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

part 'settings_screen_logic.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _imageController;
  final ImagePicker _imagePicker = ImagePicker();

  String _profileName = 'Jim Santos';
  String _profileEmail = 'jim.santos@email.com';
  String _profileImageUrl = '';
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileName);
    _emailController = TextEditingController(text: _profileEmail);
    _imageController = TextEditingController(text: _profileImageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final profileAsync = ref.watch(userProfileProvider);
    final currencyCodeAsync = ref.watch(appCurrencyCodeProvider);
    final hardBudgetModeAsync = ref.watch(appHardBudgetModeProvider);
    final thresholdAlertsAsync = ref.watch(appSpendingThresholdAlertsProvider);
    final warningLevelAsync = ref.watch(appPrimaryWarningLevelProvider);
    final ocrScannerAsync = ref.watch(appOcrScannerEnabledProvider);
    final profile = profileAsync.valueOrNull;
    final displayName = profile?.name ?? _profileName;
    final displayEmail = profile?.email ?? _profileEmail;
    final displayImageUrl = profile?.imageUrl ?? _profileImageUrl;
    final isPersistingProfile = profileAsync.isLoading;
    final activeCurrency = _currencyByCode(
      currencyCodeAsync.valueOrNull ?? _currencyPhp.code,
    );
    final hardBudgetMode = hardBudgetModeAsync.valueOrNull ?? true;
    final spendingThresholdAlerts = thresholdAlertsAsync.valueOrNull ?? true;
    final primaryWarningLevel = warningLevelAsync.valueOrNull ?? 80.0;
    final ocrScannerEnabled = ocrScannerAsync.valueOrNull ?? true;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 40,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tune your profile, shopping controls, alerts, and data preferences in one place.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF20242C),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadowColor,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFFFD658),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsOverviewCard(
              profileName: displayName.trim().isEmpty ? 'Your profile' : displayName,
              currencyLabel: activeCurrency.shortLabel,
              hardBudgetModeEnabled: hardBudgetMode,
              ocrScannerEnabled: ocrScannerEnabled,
            ),
            const SizedBox(height: 16),
            if (profileAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildErrorBanner(
                  'Failed to load profile: ${profileAsync.error}',
                ),
              ),
            if (currencyCodeAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildErrorBanner(
                  'Failed to load currency settings: ${currencyCodeAsync.error}',
                ),
              ),
            if (hardBudgetModeAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildErrorBanner(
                  'Failed to load hard budget mode: ${hardBudgetModeAsync.error}',
                ),
              ),
            if (thresholdAlertsAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildErrorBanner(
                  'Failed to load threshold alerts: ${thresholdAlertsAsync.error}',
                ),
              ),
            if (warningLevelAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildErrorBanner(
                  'Failed to load warning level: ${warningLevelAsync.error}',
                ),
              ),
            if (ocrScannerAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildErrorBanner(
                  'Failed to load OCR scanner setting: ${ocrScannerAsync.error}',
                ),
              ),
            const _SectionLabel('PROFILE DETAILS'),
            const SizedBox(height: 10),
            _buildProfileCard(
              profileName: displayName,
              profileEmail: displayEmail,
              profileImageUrl: displayImageUrl,
              isPersistingProfile: isPersistingProfile,
            ),
            const SizedBox(height: 22),
            const _SectionLabel('GENERAL'),
            const SizedBox(height: 10),
            _buildListCard([
              _InfoChevronRow(
                icon: Icons.payments_outlined,
                title: 'Currency',
                subtitle: 'Set your primary currency for tracking',
                value: activeCurrency.shortLabel,
                onTap: () => _openCurrencyPicker(activeCurrency.code),
              ),
              _InfoChevronRow(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Choose how the app looks',
                value: 'Light Mode',
                onTap: _comingSoon,
              ),
              _SwitchRow(
                icon: Icons.shield_outlined,
                title: 'Hard Budget Mode',
                subtitle: 'Prevent entries exceeding remaining funds',
                value: hardBudgetMode,
                onChanged: (value) async {
                  try {
                    await ref
                        .read(appHardBudgetModeProvider.notifier)
                        .saveHardBudgetMode(value);
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    AppSnackbars.showError(
                      context,
                      'Failed to save Hard Budget Mode.',
                    );
                  }
                },
              ),
            ]),
            const SizedBox(height: 22),
            const _SectionLabel('THRESHOLD ALERTS'),
            const SizedBox(height: 10),
            _buildSurfaceCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SwitchRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'Spending Thresholds',
                      subtitle:
                          'Receive an instant push notification when you exceed specific budget percentages.',
                      value: spendingThresholdAlerts,
                      onChanged: (value) async {
                        try {
                          await ref
                              .read(appSpendingThresholdAlertsProvider.notifier)
                              .saveEnabled(value);
                        } catch (_) {
                          if (!context.mounted) {
                            return;
                          }
                          AppSnackbars.showError(
                            context,
                            'Failed to save threshold alerts.',
                          );
                        }
                      },
                      compact: true,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      decoration: BoxDecoration(
                        color: tokens.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Primary Warning Level',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: tokens.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.textPrimary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${primaryWarningLevel.round()}%',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose when the first warning should appear during a shopping session.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            min: 50,
                            max: 95,
                            divisions: 45,
                            value: primaryWarningLevel,
                            onChanged: spendingThresholdAlerts
                                ? (value) {
                                    ref
                                        .read(
                                          appPrimaryWarningLevelProvider.notifier,
                                        )
                                        .setLocal(value);
                                  }
                                : null,
                            onChangeEnd: spendingThresholdAlerts
                                ? (value) async {
                                    try {
                                      await ref
                                          .read(
                                            appPrimaryWarningLevelProvider
                                                .notifier,
                                          )
                                          .saveLevel(value);
                                    } catch (_) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      AppSnackbars.showError(
                                        context,
                                        'Failed to save warning level.',
                                      );
                                    }
                                  }
                                : null,
                          ),
                          Row(
                            children: [
                              Text(
                                '50%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '95%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SectionLabel('FEATURES'),
            const SizedBox(height: 10),
            _buildListCard([
              const _ComingSoonFeatureRow(
                icon: Icons.psychology_alt_outlined,
                title: 'Offline AI',
                badge: '(COMING SOON)',
                subtitle:
                    'Analyze spending patterns locally without an internet connection for total privacy.',
                trailingLabel: 'SOON',
              ),
              _SwitchRow(
                icon: Icons.document_scanner_outlined,
                title: 'OCR Scanner',
                subtitle:
                    'Automatically extract item names and prices from product labels using your camera.',
                value: ocrScannerEnabled,
                onChanged: (value) async {
                  try {
                    await ref
                        .read(appOcrScannerEnabledProvider.notifier)
                        .saveEnabled(value);
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    AppSnackbars.showError(
                      context,
                      'Failed to save OCR scanner setting.',
                    );
                  }
                },
              ),
            ]),
            const SizedBox(height: 22),
            const _SectionLabel('DATA'),
            const SizedBox(height: 10),
            _buildListCard([
              _ActionRow(
                title: 'Export as CSV',
                icon: Icons.download_for_offline_outlined,
                subtitle: 'Download a spreadsheet-ready copy of your budgets and sessions.',
                onTap: _comingSoon,
              ),
              _ActionRow(
                title: 'Export as JSON',
                icon: Icons.code_outlined,
                subtitle: 'Create a structured data backup for advanced restores or migrations.',
                onTap: _comingSoon,
              ),
              _ActionRow(
                title: 'Backup data',
                icon: Icons.backup_outlined,
                subtitle: 'Save a complete local backup before changing devices.',
                onTap: _comingSoon,
              ),
            ]),
            const SizedBox(height: 22),
            const _SectionLabel('ABOUT'),
            const SizedBox(height: 10),
            _buildListCard([
              const _VersionRow(
                version: '1.0.0',
                icon: Icons.verified_outlined,
              ),
              _ActionRow(
                title: 'Privacy Policy',
                icon: Icons.open_in_new,
                subtitle: 'Review how your data is handled and stored in the app.',
                onTap: _comingSoon,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String profileName,
    required String profileEmail,
    required String profileImageUrl,
    required bool isPersistingProfile,
  }) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    final imageUrl = _isEditingProfile
        ? _imageController.text.trim()
        : profileImageUrl.trim();
    final imageProvider = _buildProfileImage(imageUrl);

    return _buildSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditingProfile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.surfaceSecondary,
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.transparent,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Icon(
                              Icons.person,
                              color: tokens.textSecondary,
                              size: 32,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROFILE',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profileName.trim().isEmpty
                              ? 'No profile name'
                              : profileName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profileEmail.trim().isEmpty
                              ? 'No email'
                              : profileEmail,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: isPersistingProfile
                        ? null
                        : () {
                            _startProfileEditing(
                              name: profileName,
                              email: profileEmail,
                              imageUrl: profileImageUrl,
                            );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.accentStrong,
                      foregroundColor: tokens.textPrimary,
                      disabledBackgroundColor: tokens.surfaceElevated,
                      disabledForegroundColor: tokens.textTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            if (!_isEditingProfile) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tokens.surfacePrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.badge_outlined,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep your profile current',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update your display name, email, and avatar so the rest of the app feels personal and tidy.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isEditingProfile) ...[
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.surfaceSecondary,
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.transparent,
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? Icon(
                                Icons.person,
                                color: tokens.textSecondary,
                                size: 34,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: tokens.accentStrong,
                        shape: const CircleBorder(),
                        elevation: 0,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: isPersistingProfile
                              ? null
                              : _pickProfileImageFromGallery,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Full Name',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Enter full name'),
              ),
              const SizedBox(height: 12),
              Text(
                'Email Address',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter email address',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelProfileEditing,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.textPrimary,
                        backgroundColor: tokens.surfacePrimary,
                        side: BorderSide(color: tokens.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: isPersistingProfile
                          ? null
                          : () async {
                              await _saveProfileEdits();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.accentStrong,
                        foregroundColor: tokens.textPrimary,
                        disabledBackgroundColor: tokens.surfaceElevated,
                        disabledForegroundColor: tokens.textTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        minimumSize: const Size.fromHeight(54),
                        elevation: 0,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(List<Widget> rows) {
    final children = <Widget>[];
    for (var index = 0; index < rows.length; index++) {
      if (index > 0) {
        children.add(const Divider(height: 1));
      }
      children.add(rows[index]);
    }
    return _buildSurfaceCard(child: Column(children: children));
  }

  Widget _buildSurfaceCard({required Widget child}) {
    final tokens = context.appThemeTokens;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildErrorBanner(String message) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tokens.warningSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tokens.warningStrong.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: tokens.warningStrong,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.warningStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _buildProfileImage(String rawPath) {
    final url = rawPath.trim();
    if (url.isEmpty) {
      return null;
    }
    final normalized = url.toLowerCase();
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return NetworkImage(url);
    }
    if (kIsWeb) {
      return null;
    }
    final file = File(url);
    if (!file.existsSync()) {
      return null;
    }
    return FileImage(file);
  }

  void _comingSoon() {
    if (!mounted) {
      return;
    }
    AppSnackbars.showSuccess(context, 'This action will be wired next.');
  }

  Future<void> _openCurrencyPicker(String selectedCode) async {
    final selected = await showModalBottomSheet<_CurrencyOption>(
      context: context,
      backgroundColor: context.appThemeTokens.backgroundCanvas,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final tokens = context.appThemeTokens;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: tokens.borderSubtle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select Currency',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 32,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose the main currency used for budgets, history, and shopping sessions.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSurfaceCard(
                  child: Column(
                    children: _supportedCurrencies
                        .map(
                          (currency) => InkWell(
                            onTap: () {
                              Navigator.of(context).pop(currency);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: selectedCode == currency.code
                                          ? tokens.accentSoft
                                          : tokens.surfaceSecondary,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.currency_exchange_rounded,
                                      color: selectedCode == currency.code
                                          ? const Color(0xFF5F950D)
                                          : tokens.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currency.label,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: tokens.textPrimary,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          currency.shortLabel,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: tokens.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (selectedCode == currency.code)
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: tokens.accentStrong,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: tokens.textPrimary,
                                        size: 18,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: tokens.textTertiary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }
    try {
      await ref
          .read(appCurrencyCodeProvider.notifier)
          .saveCurrencyCode(selected.code);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackbars.showError(context, 'Failed to save currency.');
    }
  }

  void _startProfileEditing({
    required String name,
    required String email,
    required String imageUrl,
  }) {
    _nameController.text = name;
    _emailController.text = email;
    _imageController.text = imageUrl;
    setState(() {
      _isEditingProfile = true;
    });
  }

  void _cancelProfileEditing() {
    setState(() {
      _isEditingProfile = false;
    });
  }

  Future<void> _pickProfileImageFromGallery() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (!mounted || picked == null) {
        return;
      }
      _imageController.text = picked.path;
      setState(() {});
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackbars.showError(context, 'Failed to pick image from gallery.');
    }
  }

  Future<void> _saveProfileEdits() async {
    final nextName = _nameController.text.trim();
    final nextEmail = _emailController.text.trim();
    final nextImageUrl = _imageController.text.trim();

    try {
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(
            name: nextName,
            email: nextEmail,
            imageUrl: nextImageUrl,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackbars.showError(context, 'Failed to save profile details.');
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _profileName = nextName;
      _profileEmail = nextEmail;
      _profileImageUrl = nextImageUrl;
      _isEditingProfile = false;
    });
  }
}
