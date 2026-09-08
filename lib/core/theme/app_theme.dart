import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the app's light and dark [ThemeData] from the brand palette.
/// `main.dart` wires both plus a [ThemeMode] so the OS setting is respected.
abstract final class AppTheme {
  AppTheme._();

  // Built once and reused. `MaterialApp` is rebuilt whenever the theme or
  // locale provider notifies, or the auth state changes, and each call
  // allocates a full ThemeData: a 15-style TextTheme plus a dozen-odd
  // sub-themes. The result is immutable and depends on nothing but the
  // brightness, so there is no reason to rebuild it per frame.
  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData light() =>
      _light ??= _build(Brightness.light, AppColorsX.light);
  static ThemeData dark() => _dark ??= _build(Brightness.dark, AppColorsX.dark);

  static ThemeData _build(Brightness brightness, AppColorsX appColors) {
    final colorScheme =
        brightness == Brightness.light ? _lightScheme : _darkScheme;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [appColors],
    );
    final textTheme = AppTypography.apply(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      // App bars sit flat on the parchment canvas — the comps have no coloured
      // banner. 64dp matches the comp header (`py-3` around a 40dp control).
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Cards: `bg-surface rounded-xl shadow-sm border border-divider` — the
      // hairline divider border is what separates cream cards from the
      // parchment canvas, with elevation kept low.
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        color: colorScheme.surfaceContainerLow,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      // Primary buttons: full-width fills, `text-lg` semibold, `py-4`
      // (=> 56dp min height), `rounded-xl`.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: textTheme.titleMedium,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56),
          elevation: 1,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: textTheme.titleMedium,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surfaceContainerLow,
          side: BorderSide(color: colorScheme.outlineVariant),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: textTheme.titleMedium,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      ),
      // Inputs: cream fill, `rounded-lg` (12), no resting border, 2px primary
      // focus ring, muted placeholder.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md - 4,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        // Hairline divider border at rest, matching the comp's sign-in fields
        // and the same border cards carry, then a 2px primary ring on focus.
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      // Chips are fully rounded pills in the comps.
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Bottom nav sits on the parchment canvas with a mint-tinted pill behind
      // the active destination.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall,
        ),
      ),
      // Sheets and dialogs share the card language: cream, `rounded-xl`.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        titleTextStyle: textTheme.titleLarge,
      ),
      // A snackbar rides on `inverseSurface`, so its label needs
      // `onInverseSurface`. Handing it a bare `textTheme.bodyMedium` — which
      // carries the *onSurface* ink meant for the canvas — put dark text on
      // that dark fill and made every default snackbar near-unreadable.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),
    );
  }

  /// Light scheme: harmonised from the brand seed, then the explicit brand
  /// roles are layered on top so the palette is honoured exactly.
  ///
  /// Note the surface mapping: M3's `surface` is the scaffold canvas, so it
  /// takes the *parchment* [AppPalette.background], while cards (which default
  /// to `surfaceContainerLow`) take the *cream* [AppPalette.surface]. That
  /// cream-on-parchment step is what separates cards from the canvas.
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.seed,
  ).copyWith(
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.primaryContainer,
    onPrimaryContainer: AppPalette.onPrimaryContainer,
    secondary: AppPalette.secondary,
    onSecondary: Colors.white,
    tertiary: AppPalette.accent,
    onTertiary: Colors.white,
    surface: AppPalette.background,
    onSurface: AppPalette.text,
    onSurfaceVariant: AppPalette.textMuted,
    surfaceContainerLowest: AppPalette.surfaceBright,
    surfaceContainerLow: AppPalette.surface,
    surfaceContainer: AppPalette.surfaceDim,
    outline: AppPalette.outline,
    outlineVariant: AppPalette.outlineVariant,
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
  );

  /// Dark scheme: seeded for the roles nothing names, then pinned to the
  /// explicit dark brand values. Left seed-derived, the greens came out too
  /// desaturated to read as the brand.
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.seed,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppPalette.primaryDark,
    onPrimary: AppPalette.onPrimaryDark,
    primaryContainer: AppPalette.primaryContainerDark,
    onPrimaryContainer: AppPalette.onPrimaryContainerDark,
    secondary: AppPalette.secondaryDark,
    onSecondary: AppPalette.onPrimaryDark,
    tertiary: AppPalette.accentDark,
    onTertiary: AppPalette.onWarningDark,
    surface: AppPalette.backgroundDark,
    onSurface: AppPalette.textDark,
    onSurfaceVariant: AppPalette.textMutedDark,
    surfaceContainerLowest: AppPalette.surfaceDarkLowest,
    surfaceContainerLow: AppPalette.surfaceDarkCard,
    surfaceContainer: AppPalette.surfaceDarkCard,
    outline: AppPalette.outlineDark,
    outlineVariant: AppPalette.outlineDark,
    error: AppPalette.errorDark,
    onError: AppPalette.onErrorDark,
  );
}
