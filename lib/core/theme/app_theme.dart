import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const bg = Color(0xFFF7F6F3);
    const surface = Color(0xFFFFFFFF);
    const border = Color(0xFFE6E3DD);
    const text = Color(0xFF2F2F2F);
    const muted = Color(0xFF6F6B63);
    const accent = Color(0xFF3D3A34);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: surface,
    );
    final textTheme = GoogleFonts.manropeTextTheme(
      const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: text, height: 1.3),
        bodyMedium: TextStyle(fontSize: 14, color: muted, height: 1.3),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F2EE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: accent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1EFEA),
        selectedColor: const Color(0xFFE9E6DE),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle:
            textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: text,
              fontWeight: FontWeight.w500,
            ) ??
            const TextStyle(
              fontSize: 12,
              color: text,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
