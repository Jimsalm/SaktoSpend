part of 'settings_screen.dart';

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

class _SettingsOverviewCard extends StatelessWidget {
  const _SettingsOverviewCard({
    required this.profileName,
    required this.currencyLabel,
    required this.hardBudgetModeEnabled,
    required this.ocrScannerEnabled,
  });

  final String profileName;
  final String currencyLabel;
  final bool hardBudgetModeEnabled;
  final bool ocrScannerEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(0.88, -0.06),
          radius: 1.08,
          colors: [
            tokens.accentSoft.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.97),
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SETTINGS HUB',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profileName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Everything below controls budget discipline, alerts, and label-scanning behavior across the app.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SettingsStatusChip(
                      icon: Icons.payments_outlined,
                      label: currencyLabel,
                      backgroundColor: tokens.surfaceSecondary,
                      foregroundColor: tokens.textSecondary,
                    ),
                    _SettingsStatusChip(
                      icon: hardBudgetModeEnabled
                          ? Icons.shield_rounded
                          : Icons.shield_outlined,
                      label: hardBudgetModeEnabled
                          ? 'Hard Mode On'
                          : 'Hard Mode Off',
                      backgroundColor: hardBudgetModeEnabled
                          ? tokens.accentSoft
                          : tokens.surfaceSecondary,
                      foregroundColor: hardBudgetModeEnabled
                          ? const Color(0xFF5F950D)
                          : tokens.textSecondary,
                    ),
                    _SettingsStatusChip(
                      icon: Icons.document_scanner_outlined,
                      label: ocrScannerEnabled ? 'Scanner Ready' : 'Scanner Off',
                      backgroundColor: ocrScannerEnabled
                          ? tokens.accentSoft
                          : tokens.surfaceSecondary,
                      foregroundColor: ocrScannerEnabled
                          ? const Color(0xFF5F950D)
                          : tokens.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              shape: BoxShape.circle,
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: tokens.accentStrong,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsStatusChip extends StatelessWidget {
  const _SettingsStatusChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        letterSpacing: 1.8,
        fontWeight: FontWeight.w800,
        color: tokens.textSecondary,
      ),
    );
  }
}

class _InfoChevronRow extends StatelessWidget {
  const _InfoChevronRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsLeadingIcon(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: tokens.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 0 : 16, 16, compact ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsLeadingIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.icon,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsLeadingIcon(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: tokens.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.version,
    required this.icon,
  });

  final String version;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _SettingsLeadingIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current installed release of the app.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              version,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textSecondary,
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
    required this.icon,
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final String badge;
  final String subtitle;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsLeadingIcon(icon: icon),
          const SizedBox(width: 14),
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
                          color: tokens.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '  $badge',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tokens.textSecondary,
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
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
                color: tokens.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsLeadingIcon extends StatelessWidget {
  const _SettingsLeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appThemeTokens;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: tokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: 22,
        color: tokens.textSecondary,
      ),
    );
  }
}
