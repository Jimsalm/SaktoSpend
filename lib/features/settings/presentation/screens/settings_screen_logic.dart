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
