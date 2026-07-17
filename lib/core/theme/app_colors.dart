import 'package:flutter/material.dart';

/// Raw brand palette. Use these only to *build* the [ThemeData]
/// ([AppTheme]); widgets should read colors from `Theme.of(context)` /
/// [AppColorsX] instead of referencing these directly.
abstract final class AppPalette {
  AppPalette._();

  // ── Brand roles (light) ──────────────────────────────────────────────
  static const Color primary = Color(0xFF3F72AF);
  static const Color primaryContainer = Color(0xFFDCEBFF);
  static const Color secondary = Color(0xFFF4B942); // amber
  static const Color accent = Color(0xFFFFB38A); // peach
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFF2F7FF);
  static const Color text = Color(0xFF1E2A38); // primary text / onSurface

  /// Seed for harmonising the roles the brand palette doesn't name
  /// (error, the full container ramp, etc.).
  static const Color seed = primary;

  // ── Semantic source colors (tuned per brightness in [AppColorsX]) ─────
  // success = Emerald (no brand swatch; green-for-good convention).
  static const Color success = Color(0xFF2E9E6B);
  static const Color successDark = Color(0xFF34D399);
  // warning reuses the brand secondary amber.
  static const Color warning = secondary;
  static const Color warningDark = Color(0xFFFBBF24);

  // error = a true red (the seed-derived M3 error reads pinkish on blue).
  static const Color error = Color(0xFFDC2626); // red-600
  static const Color errorContainer = Color(0xFFFEE2E2); // red-100
  static const Color onErrorContainer = Color(0xFF7F1D1D); // red-900
  static const Color errorDark = Color(0xFFF87171); // red-400
  static const Color onErrorDark = Color(0xFF450A0A); // red-950

  // Streak flame gradient (peach accent → amber secondary).
  static const Color streakStart = accent;
  static const Color streakEnd = secondary;

  // Leaderboard rank medals.
  static const Color gold = secondary;
  static const Color silver = Color(0xFF94A3B8);
  static const Color bronze = Color(0xFFB45309);

  // Text/icon colors that sit on the semantic surfaces above.
  static const Color onSuccessDark = Color(0xFF022C22);
  static const Color onWarningDark = Color(0xFF422006);
}

/// Semantic colors that have no direct Material 3 [ColorScheme] role.
///
/// Exposed via `Theme.of(context).extension<AppColorsX>()!` — never hardcode
/// `Colors.green/orange/amber` in widgets. Provides light/dark variants and
/// [lerp] so theme transitions animate.
@immutable
class AppColorsX extends ThemeExtension<AppColorsX> {
  const AppColorsX({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.streakGradientStart,
    required this.streakGradientEnd,
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color streakGradientStart;
  final Color streakGradientEnd;
  final Color gold;
  final Color silver;
  final Color bronze;

  /// Convenience for the streak flame gradient.
  List<Color> get streakGradient => [streakGradientStart, streakGradientEnd];

  static const light = AppColorsX(
    success: AppPalette.success,
    onSuccess: Colors.white,
    warning: AppPalette.warning,
    onWarning: AppPalette.text,
    streakGradientStart: AppPalette.streakStart,
    streakGradientEnd: AppPalette.streakEnd,
    gold: AppPalette.gold,
    silver: AppPalette.silver,
    bronze: AppPalette.bronze,
  );

  static const dark = AppColorsX(
    success: AppPalette.successDark,
    onSuccess: AppPalette.onSuccessDark,
    warning: AppPalette.warningDark,
    onWarning: AppPalette.onWarningDark,
    streakGradientStart: AppPalette.streakStart,
    streakGradientEnd: AppPalette.streakEnd,
    gold: AppPalette.gold,
    silver: AppPalette.silver,
    bronze: AppPalette.bronze,
  );

  @override
  AppColorsX copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? streakGradientStart,
    Color? streakGradientEnd,
    Color? gold,
    Color? silver,
    Color? bronze,
  }) {
    return AppColorsX(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      streakGradientStart: streakGradientStart ?? this.streakGradientStart,
      streakGradientEnd: streakGradientEnd ?? this.streakGradientEnd,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      bronze: bronze ?? this.bronze,
    );
  }

  @override
  AppColorsX lerp(ThemeExtension<AppColorsX>? other, double t) {
    if (other is! AppColorsX) return this;
    return AppColorsX(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      streakGradientStart:
          Color.lerp(streakGradientStart, other.streakGradientStart, t)!,
      streakGradientEnd:
          Color.lerp(streakGradientEnd, other.streakGradientEnd, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      bronze: Color.lerp(bronze, other.bronze, t)!,
    );
  }
}

/// Sugar: `context.appColors.success` instead of the verbose extension lookup.
extension AppColorsContext on BuildContext {
  AppColorsX get appColors => Theme.of(this).extension<AppColorsX>()!;
}
