import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class AppColors {
  static const surface = Color(0xFF1A1B1E);
  static const accent = Color(0xFFF6821F);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textMuted = Color(0xFF8E8E93);
  static const glassBorder = Color(0x33FFFFFF);
  static const glassBorderSubtle = Color(0x18FFFFFF);
  static const hairline = Color(0x1AFFFFFF);
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
  static const shellInset = 14.0;
}

class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
}

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.glassTintAlpha,
    required this.glassBlur,
  });

  static const baseGlassTintAlpha = 0.14;

  final double glassTintAlpha;
  final double glassBlur;

  double _intensity([double opacityMultiplier = 1.0]) =>
      glassTintAlpha * opacityMultiplier;

  Color glassTint([double opacityMultiplier = 1.0]) {
    return Colors.white.withValues(alpha: _intensity(opacityMultiplier));
  }

  Color glassTintStrong([double opacityMultiplier = 1.0]) {
    return Colors.white.withValues(alpha: _intensity(opacityMultiplier) * 1.6);
  }

  Color glassTintSubtle([double opacityMultiplier = 1.0]) {
    return Colors.white.withValues(alpha: _intensity(opacityMultiplier) * 0.55);
  }

  Color glassScrim([double opacityMultiplier = 1.0]) {
    return AppColors.surface.withValues(alpha: 0.28 * opacityMultiplier);
  }

  @Deprecated('Use glassTint instead')
  Color glassFill([double opacityMultiplier = 1.0]) => glassTint(opacityMultiplier);

  Color get glassBorder => AppColors.glassBorder;
  Color get glassBorderSubtle => AppColors.glassBorderSubtle;
  Color get textPrimary => AppColors.textPrimary;
  Color get textMuted => AppColors.textMuted;
  Color get shadowSoft => const Color(0x66000000);
  Color get hairline => AppColors.hairline;
  double get radiusLg => AppRadii.lg;
  double get radiusMd => AppRadii.md;
  double get radiusSm => AppRadii.sm;
  double get spaceSm => AppSpacing.sm;
  double get spaceMd => AppSpacing.md;
  double get spaceLg => AppSpacing.lg;
  double get shellInset => AppSpacing.shellInset;

  LinearGradient shellGradient([double opacityMultiplier = 1.0]) {
    final intensity = _intensity(opacityMultiplier);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: intensity * 1.35),
        Colors.white.withValues(alpha: intensity * 0.65),
        AppColors.surface.withValues(alpha: 0.34 * opacityMultiplier),
      ],
      stops: const [0.0, 0.42, 1.0],
    );
  }

  BoxDecoration chipDecoration([double opacityMultiplier = 1.0]) {
    return BoxDecoration(
      color: glassTintSubtle(opacityMultiplier),
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: glassBorderSubtle),
    );
  }

  BoxDecoration surfaceDecoration([double opacityMultiplier = 1.0]) {
    return BoxDecoration(
      color: glassTintSubtle(opacityMultiplier),
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: glassBorderSubtle),
    );
  }

  @override
  AppTokens copyWith({double? glassTintAlpha, double? glassBlur}) {
    return AppTokens(
      glassTintAlpha: glassTintAlpha ?? this.glassTintAlpha,
      glassBlur: glassBlur ?? this.glassBlur,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      glassTintAlpha:
          lerpDouble(glassTintAlpha, other.glassTintAlpha, t) ?? glassTintAlpha,
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

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.white.withValues(alpha: 0.04),
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF6E9FFF),
        surface: Color(0x001A1B1E),
        onSurface: AppColors.textPrimary,
        error: AppColors.statusError,
      ),
      extensions: const [
        AppTokens(glassTintAlpha: AppTokens.baseGlassTintAlpha, glassBlur: 40),
      ],
      fontFamily: '.AppleSystemUIFont',
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          letterSpacing: 0.4,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: accent.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        fillColor: Colors.white.withValues(alpha: 0.06),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.75)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface.withValues(alpha: 0.82),
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface.withValues(alpha: 0.88),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withValues(alpha: 0.55);
          }
          return Colors.white.withValues(alpha: 0.12);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}
