import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class AppColors {
  static const surface = Color(0xFF1A1B1E);
  static const panel = Color(0xFF23252A);
  static const accent = Color(0xFFF6821F);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textMuted = Color(0xFF8E8E93);
  static const glassBorder = Color(0x1FFFFFFF);
  static const hairline = Color(0x14FFFFFF);
  static const inputFill = Color(0xFF2C2F36);
  static const shadowSoft = Color(0x40000000);
  static const statusConnected = Color(0xFF34C759);
  static const statusConnecting = Color(0xFFFFCC00);
  static const statusError = Color(0xFFFF6B6B);
  static const statusOffline = Color(0xFF8E8E93);
  static const historyCompleted = Color(0xFF34C759);
  static const historyFailed = Color(0xFFFF6B6B);
  static const historyRunning = Color(0xFF6E9FFF);
}

class AppSpacing {
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

class AppRadii {
  static const md = 10.0;
  static const lg = 16.0;
}

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.glassFillAlpha,
    required this.glassBlur,
  });

  static const baseGlassFillAlpha = 0.72;

  final double glassFillAlpha;
  final double glassBlur;

  Color glassFill([double opacityMultiplier = 1.0]) {
    return AppColors.surface.withValues(
      alpha: glassFillAlpha * opacityMultiplier,
    );
  }

  Color get glassBorder => AppColors.glassBorder;
  Color get textPrimary => AppColors.textPrimary;
  Color get textMuted => AppColors.textMuted;
  Color get shadowSoft => AppColors.shadowSoft;
  Color get hairline => AppColors.hairline;
  double get radiusLg => AppRadii.lg;
  double get radiusMd => AppRadii.md;
  double get spaceSm => AppSpacing.sm;
  double get spaceMd => AppSpacing.md;
  double get spaceLg => AppSpacing.lg;

  @override
  AppTokens copyWith({double? glassFillAlpha, double? glassBlur}) {
    return AppTokens(
      glassFillAlpha: glassFillAlpha ?? this.glassFillAlpha,
      glassBlur: glassBlur ?? this.glassBlur,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      glassFillAlpha:
          lerpDouble(glassFillAlpha, other.glassFillAlpha, t) ?? glassFillAlpha,
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t) ?? glassBlur,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

class AppTheme {
  static ThemeData dark() {
    const accent = AppColors.accent;
    const panel = AppColors.panel;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF6E9FFF),
        surface: panel,
        onSurface: AppColors.textPrimary,
        error: AppColors.statusError,
      ),
      extensions: const [
        AppTokens(glassFillAlpha: AppTokens.baseGlassFillAlpha, glassBlur: 24),
      ],
      fontFamily: '.AppleSystemUIFont',
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          letterSpacing: 0.3,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: panel.withValues(alpha: 0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.glassBorder),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.6)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panel.withValues(alpha: 0.95),
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: panel.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withValues(alpha: 0.35);
          }
          return AppColors.inputFill;
        }),
      ),
    );
  }
}
