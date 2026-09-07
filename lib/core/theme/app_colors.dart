import 'package:flutter/material.dart';

/// Raw brand palette. Use these only to *build* the [ThemeData]
/// ([AppTheme]); widgets should read colors from `Theme.of(context)` /
/// [AppColorsX] instead of referencing these directly.
abstract final class AppPalette {
  AppPalette._();

  // ── Brand roles (light) ──────────────────────────────────────────────
  static const Color primary = Color(0xFF0F5233); // deep forest green
  static const Color primaryContainer = Color(0xFFD7E8DC); // pale forest tint
  static const Color onPrimaryContainer = Color(0xFF0B3D26);
  static const Color secondary = Color(0xFF339C6B); // mint
  static const Color accent = Color(0xFFC97B2E); // warm ochre

  /// Parchment canvas: the scaffold background, *behind* the cards.
  static const Color background = Color(0xFFEAEAD9);

  /// Cream card fill that sits on top of [background]. Separation comes from
  /// this cream-on-parchment step, not from heavy elevation.
  static const Color surface = Color(0xFFF4F5EB);
  static const Color surfaceBright = Color(0xFFF8F9F0);
  static const Color surfaceDim = Color(0xFFEFF0E3);

  static const Color text = Color(0xFF1D2621); // dark slate / onSurface
  static const Color textMuted = Color(0xFF757B70); // olive grey
  static const Color outline = Color(0xFFC9CAB6);
  static const Color outlineVariant = Color(0xFFD8D8C4);

  /// Seed for harmonising the roles the brand palette doesn't name
  /// (the full container ramp, inverse roles, etc.).
  static const Color seed = primary;

  // ── Brand roles (dark) ───────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF5FB98A);
  static const Color onPrimaryDark = Color(0xFF06281A);
  static const Color primaryContainerDark = Color(0xFF24493A);
  static const Color onPrimaryContainerDark = Color(0xFFC7E9D5);
  static const Color secondaryDark = Color(0xFF8AD6AE);
  static const Color accentDark = Color(0xFFE0AC4A);
  static const Color backgroundDark = Color(0xFF121710);
  static const Color surfaceDarkCard = Color(0xFF1B2118);
  static const Color surfaceDarkLowest = Color(0xFF0D110C);
  static const Color textDark = Color(0xFFEAEAD9);
  static const Color textMutedDark = Color(0xFF9BA396);
  static const Color outlineDark = Color(0xFF2C3428);

  // ── Semantic source colors (tuned per brightness in [AppColorsX]) ─────
  // Primary is now green, so success cannot simply *be* green — it would read
  // as the brand color. Success is a deeper mint than [secondary] so that
  // white label text on a success fill still clears 4.5:1; [secondary] stays
  // reserved for progress indicators that carry no text on top.
  static const Color success = Color(0xFF2A7F58);
  static const Color successDark = Color(0xFF5FD79E);

  /// Second stop for gradients that start at [success]. Previously the card
  /// faded `success` to 85% alpha, which composites *lighter* over the cream
  /// card and dropped white label text to ~3.3:1; an opaque deeper green keeps
  /// the same read at 5.6:1.
  static const Color successDeep = Color(0xFF1E6B44);
  static const Color successDeepDark = Color(0xFF3FBF85);

  /// Second stop for the brand gradient (starts at [primary]). Ending at
  /// [secondary] would push white label text to ~3.0:1, which fails AA for the
  /// small labels the prayer card puts on top of it.
  static const Color brandGradientEnd = Color(0xFF2A7F58);
  static const Color brandGradientEndDark = Color(0xFF4AA87A);
  // warning = warm ochre, the same family as the streak accent.
  static const Color warning = Color(0xFFC9922E);
  static const Color warningDark = Color(0xFFE0AC4A);

  // error = a true red, kept clearly apart from the warm ochre accents.
  static const Color error = Color(0xFFB3261E);
  static const Color errorContainer = Color(0xFFF7E2DE);
  static const Color onErrorContainer = Color(0xFF5C1710);
  static const Color errorDark = Color(0xFFF2B8B5);
  static const Color onErrorDark = Color(0xFF601410);

  // Streak flame gradient (light ochre → deep ochre).
  static const Color streakStart = Color(0xFFE9B44C);
  static const Color streakEnd = Color(0xFFC97B2E);

  // Leaderboard rank medals.
  static const Color gold = Color(0xFFC9922E);
  static const Color silver = Color(0xFF9AA096);
  static const Color bronze = Color(0xFF97562B);

  // Text/icon colors that sit on the semantic surfaces above.
  static const Color onSuccessDark = Color(0xFF06281A);
  static const Color onWarningDark = Color(0xFF3A2A08);

  /// Ink for content sitting *on* the streak gradient. The gradient is the same
  /// warm ochre in both brightnesses, so its ink must be too — reading
  /// `colorScheme.onPrimary` here gives white in light mode, which lands at
  /// roughly 1.9:1 on [streakStart].
  static const Color onStreak = Color(0xFF1D2621);
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
    required this.successDeep,
    required this.brandGradientEnd,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.streakGradientStart,
    required this.streakGradientEnd,
    required this.onStreak,
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  final Color success;

  /// Deeper second stop for gradients beginning at [success].
  final Color successDeep;

  /// Second stop for the brand gradient beginning at `colorScheme.primary`.
  /// Kept dark enough that `onPrimary` clears 4.5:1 on top of it.
  final Color brandGradientEnd;

  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color streakGradientStart;
  final Color streakGradientEnd;

  /// Ink for text and icons drawn on top of [streakGradient].
  final Color onStreak;
  final Color gold;
  final Color silver;
  final Color bronze;

  /// Convenience for the streak flame gradient.
  List<Color> get streakGradient => [streakGradientStart, streakGradientEnd];

  static const light = AppColorsX(
    success: AppPalette.success,
    successDeep: AppPalette.successDeep,
    brandGradientEnd: AppPalette.brandGradientEnd,
    onSuccess: Colors.white,
    warning: AppPalette.warning,
    onWarning: AppPalette.text,
    streakGradientStart: AppPalette.streakStart,
    streakGradientEnd: AppPalette.streakEnd,
    onStreak: AppPalette.onStreak,
    gold: AppPalette.gold,
    silver: AppPalette.silver,
    bronze: AppPalette.bronze,
  );

  static const dark = AppColorsX(
    success: AppPalette.successDark,
    successDeep: AppPalette.successDeepDark,
    brandGradientEnd: AppPalette.brandGradientEndDark,
    onSuccess: AppPalette.onSuccessDark,
    warning: AppPalette.warningDark,
    onWarning: AppPalette.onWarningDark,
    streakGradientStart: AppPalette.streakStart,
    streakGradientEnd: AppPalette.streakEnd,
    onStreak: AppPalette.onStreak,
    gold: AppPalette.gold,
    silver: AppPalette.silver,
    bronze: AppPalette.bronze,
  );

  @override
  AppColorsX copyWith({
    Color? success,
    Color? successDeep,
    Color? brandGradientEnd,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? streakGradientStart,
    Color? streakGradientEnd,
    Color? onStreak,
    Color? gold,
    Color? silver,
    Color? bronze,
  }) {
    return AppColorsX(
      success: success ?? this.success,
      successDeep: successDeep ?? this.successDeep,
      brandGradientEnd: brandGradientEnd ?? this.brandGradientEnd,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      streakGradientStart: streakGradientStart ?? this.streakGradientStart,
      streakGradientEnd: streakGradientEnd ?? this.streakGradientEnd,
      onStreak: onStreak ?? this.onStreak,
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
      successDeep: Color.lerp(successDeep, other.successDeep, t)!,
      brandGradientEnd:
          Color.lerp(brandGradientEnd, other.brandGradientEnd, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      streakGradientStart:
          Color.lerp(streakGradientStart, other.streakGradientStart, t)!,
      streakGradientEnd:
          Color.lerp(streakGradientEnd, other.streakGradientEnd, t)!,
      onStreak: Color.lerp(onStreak, other.onStreak, t)!,
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
