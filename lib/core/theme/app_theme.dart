import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the app's light and dark [ThemeData] from the brand seed and tokens.
/// `main.dart` wires both plus a [ThemeMode] so the OS setting is respected.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColorsX.light);
  static ThemeData dark() => _build(Brightness.dark, AppColorsX.dark);

  static ThemeData _build(Brightness brightness, AppColorsX appColors) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.seed,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [appColors],
    );

    return base.copyWith(
      textTheme: AppTypography.apply(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: AppRadius.brSm),
      ),
    );
  }
}