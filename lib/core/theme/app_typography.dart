import 'package:flutter/material.dart';

/// App text theme, matching the design system: Plus Jakarta Sans for display,
/// headline and title levels, Noto Sans for body and label levels.
///
/// Sizes started from the comps, which are built on Tailwind's type scale
/// (`text-xs` 12 → `text-6xl` 60) at a 390pt viewport, so those values map
/// 1:1 onto Flutter logical pixels. The Material 3 defaults are noticeably
/// larger than that scale, so each role is pinned here rather than inherited —
/// this is what keeps every screen on one type system instead of each widget
/// hard-coding its own `fontSize`.
///
/// The display and headline tiers now sit one step below the comp tokens.
/// Checked on device, the comp values read oversized: the Fajr hero at 60
/// nearly spanned the card with its meridiem, and the greeting at 30 wrapped
/// onto two lines for an ordinary name. Body, label and title tiers are
/// untouched — only the top of the ramp was compressed, so the hierarchy
/// between levels is unchanged.
///
/// | role          | comp token   | comp px | here |
/// |---------------|--------------|---------|------|
/// | displayLarge  | `text-6xl`   | 60      | 48   |
/// | displayMedium | `text-5xl`   | 48      | 40   |
/// | displaySmall  | `text-4xl`   | 36      | 32   |
/// | headlineLarge | `text-4xl`   | 36      | 30   |
/// | headlineMedium| `text-3xl`   | 30      | 26   |
/// | headlineSmall | `text-2xl`   | 24      | 24   |
/// | titleLarge    | `text-xl`    | 20      | 20   |
/// | titleMedium   | `text-lg`    | 18      | 18   |
/// | body/label    | `text-base/sm/xs` | 16/14/12 | same |
///
/// Both families are bundled as variable fonts (see `pubspec.yaml`), so each
/// style sets `fontVariations` alongside `fontWeight`. `fontWeight` alone is
/// honoured inconsistently across platforms for a variable font declared as a
/// single asset — driving the `wght` axis explicitly renders the intended
/// weight everywhere.
///
/// Colors are left untouched: this takes the brightness-correct base
/// [TextTheme] that `ThemeData` derives from the [ColorScheme], so text stays
/// readable in both light and dark mode.
///
/// The bundled families cover Latin only. Arabic, Bengali and Urdu glyphs fall
/// through to the platform's own fonts via the engine's default fallback chain.
abstract final class AppTypography {
  AppTypography._();

  static const String headlineFamily = 'PlusJakartaSans';
  static const String bodyFamily = 'NotoSans';

  /// Tight leading for large display/headline text, per the comps.
  static const double _tight = 1.15;
  static const double _snug = 1.3;
  static const double _relaxed = 1.5;

  static TextStyle? _display(
    TextStyle? base,
    double size,
    FontWeight weight, {
    double height = _tight,
  }) =>
      base?.copyWith(
        fontFamily: headlineFamily,
        fontSize: size,
        height: height,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
      );

  static TextStyle? _body(
    TextStyle? base,
    double size,
    FontWeight weight, {
    double height = _relaxed,
  }) =>
      base?.copyWith(
        fontFamily: bodyFamily,
        fontSize: size,
        height: height,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
      );

  static TextTheme apply(TextTheme base) {
    return base.copyWith(
      // Display — the big numerals: Fajr time and streak count.
      displayLarge: _display(base.displayLarge, 48, FontWeight.bold),
      displayMedium: _display(base.displayMedium, 40, FontWeight.bold),
      displaySmall: _display(base.displaySmall, 32, FontWeight.bold),
      // Headline — screen titles and greetings.
      headlineLarge: _display(base.headlineLarge, 30, FontWeight.bold),
      headlineMedium: _display(base.headlineMedium, 26, FontWeight.bold),
      headlineSmall: _display(base.headlineSmall, 24, FontWeight.bold),
      // Title — card and section headers, semibold in the comps.
      titleLarge: _display(base.titleLarge, 20, FontWeight.w600,
          height: _snug),
      titleMedium: _display(base.titleMedium, 18, FontWeight.w600,
          height: _snug),
      titleSmall: _display(base.titleSmall, 16, FontWeight.w600,
          height: _snug),
      // Body — Noto Sans, regular.
      bodyLarge: _body(base.bodyLarge, 16, FontWeight.w400),
      bodyMedium: _body(base.bodyMedium, 14, FontWeight.w400),
      bodySmall: _body(base.bodySmall, 12, FontWeight.w400),
      // Labels — buttons, chips, nav. Medium weight, tighter leading.
      labelLarge: _body(base.labelLarge, 16, FontWeight.w600, height: _snug),
      labelMedium: _body(base.labelMedium, 14, FontWeight.w500, height: _snug),
      labelSmall: _body(base.labelSmall, 12, FontWeight.w500, height: _snug),
    );
  }
}
