import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const tokens = AppThemeTokens.light();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: tokens.accentStrong,
      brightness: Brightness.light,
      surface: tokens.surfacePrimary,
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
      extensions: const <ThemeExtension<dynamic>>[tokens],
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: tokens.accentStrong,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF141414),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        actionTextColor: const Color(0xFFEDE7DA),
        showCloseIcon: true,
        closeIconColor: const Color(0xFFF1EFEA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2F2F2F)),
        ),
        elevation: 6,
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
    : backgroundCanvas = const Color(0xFFF4F6FB),
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

  @override
  AppThemeTokens copyWith({
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
      backgroundCanvas: Color.lerp(backgroundCanvas, other.backgroundCanvas, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
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
      Theme.of(this).extension<AppThemeTokens>() ?? const AppThemeTokens.light();
}
