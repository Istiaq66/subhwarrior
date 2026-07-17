import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the app's light and dark [ThemeData] from the brand palette.
/// `main.dart` wires both plus a [ThemeMode] so the OS setting is respected.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColorsX.light);
  static ThemeData dark() => _build(Brightness.dark, AppColorsX.dark);

  static ThemeData _build(Brightness brightness, AppColorsX appColors) {
    final colorScheme =
        brightness == Brightness.light ? _lightScheme : _darkScheme;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [appColors],
    );

    return base.copyWith(
      textTheme: AppTypography.apply(base.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: AppRadius.brSm),
        filled: true,
      ),
    );
  }

  /// Light scheme: harmonised from the brand seed, then the explicit brand
  /// roles are layered on top so the palette is honoured exactly.
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.seed,
  ).copyWith(
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.primaryContainer,
    onPrimaryContainer: AppPalette.text,
    secondary: AppPalette.secondary,
    onSecondary: AppPalette.text,
    tertiary: AppPalette.accent,
    onTertiary: AppPalette.text,
    surface: AppPalette.surface,
    onSurface: AppPalette.text,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: AppPalette.surface,
    surfaceContainer: AppPalette.background,
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
  );

  /// Dark scheme: seed-derived (proper dark surfaces/contrast) with the
  /// brand secondary/tertiary kept so the accent identity survives.
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.seed,
    brightness: Brightness.dark,
  ).copyWith(
    secondary: AppPalette.secondary,
    tertiary: AppPalette.accent,
    error: AppPalette.errorDark,
    onError: AppPalette.onErrorDark,
  );
}
