import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic snackbar flavours.
///
/// Each flavour pairs a fill with the ink that reads on it, and that pairing is
/// the whole point: [SnackBarThemeData.contentTextStyle] carries the neutral
/// `onInverseSurface` ink, so a call site that overrides `backgroundColor`
/// alone keeps the neutral label colour over its new fill. Every semantic
/// snackbar in the app used to do exactly that.
enum AppSnackKind { neutral, error, warning, success }

/// Matches Flutter's own `SnackBar` default, which isn't exposed as a constant.
const Duration _defaultDuration = Duration(milliseconds: 4000);

/// Builds a themed snackbar whose label and action colours match [kind]'s
/// fill. [AppSnackKind.neutral] leaves both to `snackBarTheme`.
SnackBar appSnackBar(
  BuildContext context,
  String message, {
  AppSnackKind kind = AppSnackKind.neutral,
  SnackBarAction? action,
  Duration? duration,
}) {
  final theme = Theme.of(context);
  final appColors = context.appColors;

  final (Color? background, Color? foreground) = switch (kind) {
    AppSnackKind.neutral => (null, null),
    AppSnackKind.error => (
        theme.colorScheme.error,
        theme.colorScheme.onError,
      ),
    AppSnackKind.warning => (appColors.warning, appColors.onWarning),
    AppSnackKind.success => (appColors.success, appColors.onSuccess),
  };

  return SnackBar(
    // `SnackBar` has no `contentTextStyle`, so the semantic ink rides on the
    // label itself; the neutral flavour keeps `snackBarTheme`'s style.
    content: Text(
      message,
      style: foreground == null
          ? null
          : (theme.snackBarTheme.contentTextStyle ?? theme.textTheme.bodyMedium)
              ?.copyWith(color: foreground),
    ),
    backgroundColor: background,
    duration: duration ?? _defaultDuration,
    // `snackBarTheme.actionTextColor` is tuned for the neutral fill, so a
    // semantic snackbar re-labels its action in its own ink.
    action: action == null || foreground == null
        ? action
        : SnackBarAction(
            label: action.label,
            onPressed: action.onPressed,
            textColor: foreground,
          ),
  );
}

/// Sugar: `context.showSnack('Saved', kind: AppSnackKind.success)`.
extension AppSnackBarContext on BuildContext {
  void showSnack(
    String message, {
    AppSnackKind kind = AppSnackKind.neutral,
    SnackBarAction? action,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(appSnackBar(
      this,
      message,
      kind: kind,
      action: action,
      duration: duration,
    ));
  }
}