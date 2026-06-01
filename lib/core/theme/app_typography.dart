import 'package:flutter/material.dart';

/// App text theme. Tokenizes the font weights that were previously scattered
/// as inline `TextStyle(fontSize: 24, fontWeight: bold)`.
///
/// Uses the platform default font (no `google_fonts` dependency, so it works
/// offline and in CI). Takes the brightness-correct base [TextTheme] that
/// `ThemeData` derives from the [ColorScheme] and only bumps weights, so text
/// colors stay correct in both light and dark mode. Widgets should read styles
/// via `Theme.of(context).textTheme.*`.
abstract final class AppTypography {
  AppTypography._();

  static TextTheme apply(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.bold),
      headlineMedium:
          base.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
