import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_snack_bars.dart';

/// Whether a location lookup may proceed, and if not, what is standing in the
/// way — each case sends the user somewhere different.
enum LocationAccess { granted, serviceDisabled, denied, blocked }

/// How long a location snack stays up.
const Duration locationSnackDuration = Duration(seconds: 5);

/// Resolves the location service state and permission, prompting once if the
/// permission has never been answered.
Future<LocationAccess> requestLocationAccess() async {
  // Location switched off at the OS level: the permission dialog never
  // appears, so this has to be reported separately from a denial.
  if (!await Geolocator.isLocationServiceEnabled()) {
    return LocationAccess.serviceDisabled;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return switch (permission) {
    LocationPermission.denied => LocationAccess.denied,
    LocationPermission.deniedForever => LocationAccess.blocked,
    _ => LocationAccess.granted,
  };
}

/// Explains [access] and offers the shortcut that can fix it. No-op once
/// access is granted.
///
/// No platform exposes a deep link to the per-app location permission itself,
/// so a blocked permission lands on the app's settings page and the copy names
/// the remaining taps for that platform. A disabled service does have an exact
/// destination: the system location page.
void showLocationAccessSnack(BuildContext context, LocationAccess access) {
  if (access == LocationAccess.granted) return;

  final l10n = AppLocalizations.of(context)!;
  final isIos = Theme.of(context).platform == TargetPlatform.iOS;

  final (String message, String label, VoidCallback onAction) =
      switch (access) {
    LocationAccess.serviceDisabled => (
        l10n.locationServicesOff,
        l10n.locationTurnOnAction,
        Geolocator.openLocationSettings,
      ),
    LocationAccess.denied => (
        l10n.locationPermissionDenied,
        l10n.locationOpenSettingsAction,
        Geolocator.openAppSettings,
      ),
    _ => (
        isIos
            ? l10n.locationPermissionBlockedIos
            : l10n.locationPermissionBlockedAndroid,
        l10n.locationOpenSettingsAction,
        Geolocator.openAppSettings,
      ),
  };

  showLocationSnack(
    context,
    message,
    kind: AppSnackKind.warning,
    actionLabel: label,
    onAction: onAction,
  );
}

/// Shows a location snack, replacing any still on screen.
///
/// Every failed attempt used to queue one more snack, and the messenger plays
/// its queue one entry at a time, so a user who tapped the button a few times
/// watched the same message reappear long after they had read it. Clearing
/// first keeps at most one on screen; [appSnackBar] handles the timeout, which
/// `SnackBar` would otherwise disable for a snackbar carrying an action.
void showLocationSnack(
  BuildContext context,
  String message, {
  required AppSnackKind kind,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context)..clearSnackBars();

  messenger.showSnackBar(
    appSnackBar(
      context,
      message,
      kind: kind,
      duration: locationSnackDuration,
      action: actionLabel == null || onAction == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction),
    ),
  );
}
