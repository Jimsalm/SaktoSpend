import 'dart:io';

import 'package:SaktoSpend/app/providers/providers.dart';
import 'package:SaktoSpend/core/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 52),
                ),
                const Spacer(),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (profileAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Failed to load profile: ${profileAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ),
            if (currencyCodeAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Failed to load currency settings: ${currencyCodeAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ),
            if (hardBudgetModeAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Failed to load hard budget mode: ${hardBudgetModeAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ),
            if (thresholdAlertsAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Failed to load threshold alerts: ${thresholdAlertsAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ),
            if (warningLevelAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Failed to load warning level: ${warningLevelAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ),
            if (ocrScannerAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Failed to load OCR scanner setting: ${ocrScannerAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ),
            const _SectionLabel('PROFILE DETAILS'),
            const SizedBox(height: 8),
            _buildProfileCard(
              profileName: displayName,
              profileEmail: displayEmail,
              profileImageUrl: displayImageUrl,
              isPersistingProfile: isPersistingProfile,
            ),
            const SizedBox(height: 18),
            const _SectionLabel('GENERAL'),
            const SizedBox(height: 8),
            _buildListCard([
              _InfoChevronRow(
                title: 'Currency',
                subtitle: 'Set your primary currency for tracking',
                value: activeCurrency.shortLabel,
                onTap: () => _openCurrencyPicker(activeCurrency.code),
              ),
              _InfoChevronRow(
                title: 'Theme',
                subtitle: 'Choose how the app looks',
                value: 'Light',
                onTap: _comingSoon,
              ),
              _SwitchRow(
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
            const SizedBox(height: 18),
            const _SectionLabel('THRESHOLD ALERTS'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  children: [
                    _SwitchRow(
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Primary Warning Level',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A362F),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${primaryWarningLevel.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF111111),
                        inactiveTrackColor: const Color(0xFFD9D5CC),
                        thumbColor: Colors.black,
                        trackHeight: 3.2,
                        overlayColor: Colors.black12,
                      ),
                      child: Slider(
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
                                        appPrimaryWarningLevelProvider.notifier,
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
                    ),
                    const Row(
                      children: [
                        Text('50%', style: TextStyle(fontSize: 12)),
                        Spacer(),
                        Text('95%', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const _SectionLabel('FEATURES'),
            const SizedBox(height: 8),
            _buildListCard([
              const _ComingSoonFeatureRow(
                title: 'Offline AI',
                badge: '(COMING SOON)',
                subtitle:
                    'Analyze spending patterns locally without an internet connection for total privacy.',
                trailingLabel: 'SOON',
              ),
              _SwitchRow(
                title: 'OCR Scanner',
                subtitle:
                    'Automatically extract items and prices from physical receipts using your camera.',
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
            const SizedBox(height: 18),
            const _SectionLabel('DATA'),
            const SizedBox(height: 8),
            _buildListCard([
              _ActionRow(
                title: 'Export as CSV',
                icon: Icons.download_for_offline_outlined,
                onTap: _comingSoon,
              ),
              _ActionRow(
                title: 'Export as JSON',
                icon: Icons.code_outlined,
                onTap: _comingSoon,
              ),
              _ActionRow(
                title: 'Backup data',
                icon: Icons.backup_outlined,
                onTap: _comingSoon,
              ),
            ]),
            const SizedBox(height: 18),
            const _SectionLabel('ABOUT'),
            const SizedBox(height: 8),
            _buildListCard([
              const _VersionRow(version: '1.0.0'),
              _ActionRow(
                title: 'Privacy Policy',
                icon: Icons.open_in_new,
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
    final imageUrl = _isEditingProfile
        ? _imageController.text.trim()
        : profileImageUrl.trim();
    final imageProvider = _buildProfileImage(imageUrl);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditingProfile)
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE6E2D9),
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(Icons.person, color: Color(0xFF5D574D))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileName.trim().isEmpty
                              ? 'No profile name'
                              : profileName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profileEmail.trim().isEmpty
                              ? 'No email'
                              : profileEmail,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF5F5A52)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: isPersistingProfile
                        ? null
                        : () {
                            _startProfileEditing(
                              name: profileName,
                              email: profileEmail,
                              imageUrl: profileImageUrl,
                            );
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2F2F2F),
                      backgroundColor: const Color(0xFFF1EFEA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFE6E3DD)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            if (_isEditingProfile) ...[
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFE6E2D9),
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(
                              Icons.person,
                              color: Color(0xFF5D574D),
                              size: 30,
                            )
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 1.2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: isPersistingProfile
                              ? null
                              : _pickProfileImageFromGallery,
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF2F2F2F),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5F5A52),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5F5A52),
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
                    child: TextButton(
                      onPressed: _cancelProfileEditing,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2F2F2F),
                        backgroundColor: const Color(0xFFF1EFEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFFE6E3DD)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
    return Card(child: Column(children: children));
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
      backgroundColor: const Color(0xFFF7F6F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Currency',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: _supportedCurrencies
                        .map(
                          (currency) => ListTile(
                            onTap: () {
                              Navigator.of(context).pop(currency);
                            },
                            title: Text(
                              currency.label,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              currency.shortLabel,
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: selectedCode == currency.code
                                ? const Icon(
                                    Icons.check,
                                    color: Color(0xFF111111),
                                  )
                                : const SizedBox.shrink(),
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

_CurrencyOption _currencyByCode(String? code) {
  final normalized = code?.trim().toUpperCase() ?? '';
  for (final currency in _supportedCurrencies) {
    if (currency.code == normalized) {
      return currency;
    }
  }
  return _currencyPhp;
}

class _CurrencyOption {
  const _CurrencyOption({
    required this.code,
    required this.label,
    required this.shortLabel,
  });

  final String code;
  final String label;
  final String shortLabel;
}

const _currencyUsd = _CurrencyOption(
  code: 'USD',
  label: 'US Dollar',
  shortLabel: 'USD (\$)',
);
const _currencyEur = _CurrencyOption(
  code: 'EUR',
  label: 'Euro',
  shortLabel: 'EUR (€)',
);
const _currencyJpy = _CurrencyOption(
  code: 'JPY',
  label: 'Japanese Yen',
  shortLabel: 'JPY (¥)',
);
const _currencyAud = _CurrencyOption(
  code: 'AUD',
  label: 'Australian Dollar',
  shortLabel: 'AUD (A\$)',
);
const _currencyPhp = _CurrencyOption(
  code: 'PHP',
  label: 'Philippine Peso',
  shortLabel: 'PHP (₱)',
);

const _supportedCurrencies = <_CurrencyOption>[
  _currencyUsd,
  _currencyEur,
  _currencyJpy,
  _currencyAud,
  _currencyPhp,
];

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        letterSpacing: 2,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF5B574F),
      ),
    );
  }
}

class _InfoChevronRow extends StatelessWidget {
  const _InfoChevronRow({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F5A52),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF5A554D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFF8A857C)),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 0 : 14, 16, compact ? 0 : 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F5A52),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF111111),
            activeThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD6D3CC),
            inactiveThumbColor: const Color(0xFF726D63),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(icon, size: 18, color: const Color(0xFF8E897F)),
          ],
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Version',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFEA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              version,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7D776D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonFeatureRow extends StatelessWidget {
  const _ComingSoonFeatureRow({
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.trailingLabel,
  });

  final String title;
  final String badge;
  final String subtitle;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F2F2F),
                        ),
                      ),
                      TextSpan(
                        text: '  $badge',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9A958C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4E4A43),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              trailingLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 3.2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB2AEA6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
