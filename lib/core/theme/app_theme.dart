import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _build(const AppThemeTokens.light());
  }

  static ThemeData dark() {
    return _build(const AppThemeTokens.dark());
  }

  static ThemeData _build(AppThemeTokens tokens) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: tokens.accentStrong,
          brightness: tokens.brightness,
          surface: tokens.surfacePrimary,
        ).copyWith(
          primary: tokens.accentStrong,
          onPrimary: tokens.onAccentStrong,
          surface: tokens.surfacePrimary,
          onSurface: tokens.textPrimary,
          error: tokens.warningStrong,
          onError: Colors.white,
          outline: tokens.borderSubtle,
          shadow: tokens.shadowColor,
        );
    final textTheme = GoogleFonts.manropeTextTheme(
      TextTheme(
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: tokens.textPrimary,
          height: 1.32,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: tokens.textSecondary,
          height: 1.32,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.backgroundCanvas,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      cardTheme: CardThemeData(
        color: tokens.surfacePrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: tokens.shadowColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfacePrimary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: tokens.backgroundCanvas,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tokens.accentStrong, width: 1.2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: tokens.onAccentStrong,
        backgroundColor: tokens.accentStrong,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.accentStrong,
          foregroundColor: tokens.onAccentStrong,
          disabledBackgroundColor: tokens.surfaceElevated,
          disabledForegroundColor: tokens.textTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return tokens.surfacePrimary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.accentStrong;
          }
          return tokens.surfaceElevated;
        }),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: tokens.accentStrong,
        inactiveTrackColor: tokens.surfaceElevated,
        thumbColor: tokens.accentStrong,
        overlayColor: tokens.accentStrong.withValues(alpha: 0.16),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.surfacePrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        actionTextColor: tokens.textPrimary,
        showCloseIcon: true,
        closeIconColor: tokens.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: tokens.borderSubtle),
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceSecondary,
        selectedColor: tokens.accentSoft,
        side: BorderSide(color: tokens.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle:
            textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: tokens.textPrimary,
              fontWeight: FontWeight.w500,
            ) ??
            TextStyle(
              fontSize: 12,
              color: tokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.brightness,
    required this.backgroundCanvas,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentStrong,
    required this.accentSoft,
    required this.warningStrong,
    required this.warningSoft,
    required this.shadowColor,
  });

  const AppThemeTokens.light()
    : brightness = Brightness.light,
      backgroundCanvas = const Color(0xFFF4F6FB),
      surfacePrimary = const Color(0xFFFFFFFF),
      surfaceSecondary = const Color(0xFFF1F4F8),
      surfaceElevated = const Color(0xFFE6EBF3),
      borderSubtle = const Color(0xFFE7EDF5),
      textPrimary = const Color(0xFF0D1530),
      textSecondary = const Color(0xFF607496),
      textTertiary = const Color(0xFF93A0B7),
      accentStrong = const Color(0xFFA4ED23),
      accentSoft = const Color(0xFFE8F7BF),
      warningStrong = const Color(0xFFE52420),
      warningSoft = const Color(0xFFFFE8E5),
      shadowColor = const Color(0x160D2340);

  const AppThemeTokens.dark()
    : brightness = Brightness.dark,
      backgroundCanvas = const Color(0xFF09111A),
      surfacePrimary = const Color(0xFF0E1723),
      surfaceSecondary = const Color(0xFF151F2C),
      surfaceElevated = const Color(0xFF1C2735),
      borderSubtle = const Color(0xFF213042),
      textPrimary = const Color(0xFFF4F7FF),
      textSecondary = const Color(0xFF9CA9C5),
      textTertiary = const Color(0xFF738099),
      accentStrong = const Color(0xFFB8F72C),
      accentSoft = const Color(0xFF233115),
      warningStrong = const Color(0xFFFF4A44),
      warningSoft = const Color(0xFF351718),
      shadowColor = const Color(0x14000912);

  final Brightness brightness;
  final Color backgroundCanvas;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accentStrong;
  final Color accentSoft;
  final Color warningStrong;
  final Color warningSoft;
  final Color shadowColor;

  bool get isDark => brightness == Brightness.dark;

  Color get onAccentStrong => isDark ? backgroundCanvas : textPrimary;
  Color get accentInk =>
      isDark ? const Color(0xFF89D61A) : const Color(0xFF5F950D);
  Color get accentInkStrong =>
      isDark ? const Color(0xFF98EA1B) : const Color(0xFF69A80D);
  Color get progressTrack =>
      isDark ? surfaceSecondary : const Color(0xFFD9E0EB);
  Color get progressCap =>
      isDark ? const Color(0xFFDDFB8C) : const Color(0xFFDDFB8C);
  Color get warningProgressCap =>
      isDark ? warningStrong.withValues(alpha: 0.72) : const Color(0xFFFFC9C6);
  Color get heroIconSurface => isDark
      ? surfaceSecondary.withValues(alpha: 0.9)
      : Colors.white.withValues(alpha: 0.94);
  Color get pillSurface => isDark
      ? surfaceSecondary.withValues(alpha: 0.96)
      : Colors.white.withValues(alpha: 0.9);
  Color get avatarSurface =>
      isDark ? const Color(0xFF131D2A) : const Color(0xFF20242C);
  Color get avatarIconColor => isDark ? accentStrong : const Color(0xFFFFD658);
  Color get overlayStroke => isDark
      ? Colors.white.withValues(alpha: 0.12)
      : Colors.white.withValues(alpha: 0.58);
  Color get overlayHighlightStrong => isDark
      ? Colors.white.withValues(alpha: 0.12)
      : Colors.white.withValues(alpha: 0.22);
  Color get overlayHighlightSoft => isDark
      ? Colors.white.withValues(alpha: 0.02)
      : Colors.white.withValues(alpha: 0.02);
  Color get scrimColor => isDark
      ? Colors.black.withValues(alpha: 0.42)
      : Colors.black.withValues(alpha: 0.24);
  Color get hardModeBadgeBackground => isDark ? surfaceSecondary : textPrimary;
  Color get hardModeBadgeText => isDark ? textPrimary : Colors.white;
  Color get hardModeBadgeIcon => isDark ? accentStrong : Colors.white;
  Color get actionIconTintSurface => isDark
      ? backgroundCanvas.withValues(alpha: 0.18)
      : Colors.white.withValues(alpha: 0.34);

  List<Color> heroGradientColors({Color? glowColor}) {
    final baseGlow = glowColor ?? accentSoft;
    if (isDark) {
      return [
        baseGlow.withValues(alpha: 0.95),
        surfacePrimary.withValues(alpha: 0.98),
        surfacePrimary,
      ];
    }
    return [
      baseGlow.withValues(alpha: 0.95),
      Colors.white.withValues(alpha: 0.97),
      Colors.white,
    ];
  }

  List<Color> positiveProgressGradientColors() {
    if (isDark) {
      return const [Color(0xFF98EA1B), Color(0xFFC9F96E)];
    }
    return const [Color(0xFF98EA1B), Color(0xFFC9F96E)];
  }

  List<Color> warningProgressGradientColors() {
    if (isDark) {
      return [warningStrong, const Color(0xFFFF7B75)];
    }
    return const [Color(0xFFF46B66), Color(0xFFFFA19C)];
  }

  @override
  AppThemeTokens copyWith({
    Brightness? brightness,
    Color? backgroundCanvas,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceElevated,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accentStrong,
    Color? accentSoft,
    Color? warningStrong,
    Color? warningSoft,
    Color? shadowColor,
  }) {
    return AppThemeTokens(
      brightness: brightness ?? this.brightness,
      backgroundCanvas: backgroundCanvas ?? this.backgroundCanvas,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accentStrong: accentStrong ?? this.accentStrong,
      accentSoft: accentSoft ?? this.accentSoft,
      warningStrong: warningStrong ?? this.warningStrong,
      warningSoft: warningSoft ?? this.warningSoft,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }
    return AppThemeTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      backgroundCanvas: Color.lerp(
        backgroundCanvas,
        other.backgroundCanvas,
        t,
      )!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      warningStrong: Color.lerp(warningStrong, other.warningStrong, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

extension AppThemeTokensLookup on BuildContext {
  AppThemeTokens get appThemeTokens =>
      Theme.of(this).extension<AppThemeTokens>() ??
      const AppThemeTokens.light();
}
