import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const surface = Color(0xFF1A1B1E);
    const panel = Color(0xFF23252A);
    const accent = Color(0xFFF6821F);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF6E9FFF),
        surface: panel,
        error: Color(0xFFFF6B6B),
      ),
      fontFamily: '.AppleSystemUIFont',
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 13, height: 1.4),
        labelSmall: TextStyle(fontSize: 11, letterSpacing: 0.3),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2F36),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF34373F),
        thickness: 1,
      ),
    );
  }
}
