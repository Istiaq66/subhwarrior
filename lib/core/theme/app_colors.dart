import 'package:flutter/material.dart';

/// Raw brand palette. Use these only to *build* the [ThemeData]
/// ([AppTheme]); widgets should read colors from `Theme.of(context)` /
/// [AppColorsX] instead of referencing these directly.
abstract final class AppPalette {
  AppPalette._();

  /// Islamic green — the seed for the Material 3 [ColorScheme].
  static const Color seed = Color(0xFF1B5E20);

  // Semantic source colors (tuned per brightness in [AppColorsX]).
  static const Color success = Color(0xFF2E7D32);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningDark = Color(0xFFFFB74D);

  // Streak flame gradient.
  static const Color streakStart = Color(0xFFFF6D00);
  static const Color streakEnd = Color(0xFFFFA726);

  // Leaderboard rank medals.
  static const Color gold = Color(0xFFFFC107);
  static const Color silver = Color(0xFFBDBDBD);
  static const Color bronze = Color(0xFF8D6E63);
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
    onWarning: Colors.white,
    streakGradientStart: AppPalette.streakStart,
    streakGradientEnd: AppPalette.streakEnd,
    gold: AppPalette.gold,
    silver: AppPalette.silver,
    bronze: AppPalette.bronze,
  );

  static const dark = AppColorsX(
    success: AppPalette.successDark,
    onSuccess: Color(0xFF003300),
    warning: AppPalette.warningDark,
    onWarning: Color(0xFF3E2600),
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
