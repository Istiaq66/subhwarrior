import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';

const int notificationPermissionLaunchLimit = 31;
const int notificationPermissionLaunchInterval = 10;
const String keyLaunchCountForNotificationPermission =
    'launch_count_notification_permission';

/// After "Not now", how long before Home asks again for features the user
/// has switched on.
const Duration notificationPermissionSnooze = Duration(days: 1);
const String keyNotificationPermissionSnoozedUntil =
    'notification_permission_snoozed_until_ms';

/// Whether Home should ask for the notification permission on this launch.
///
/// [featuresNeedIt] — reminders or the Fajr call are on — asks on every launch
/// until granted, short of a snooze. Those switches sync from the account, so
/// a fresh install can arrive with them on while the OS permission starts out
/// denied, and the launch cadence alone left it that way silently. Otherwise
/// the occasional nudge on launches 1, 11, 21 and 31 applies.
bool shouldPromptForNotifications({
  required bool featuresNeedIt,
  required int launchCount,
  required DateTime now,
  DateTime? snoozedUntil,
}) {
  if (featuresNeedIt) {
    return snoozedUntil == null || !now.isBefore(snoozedUntil);
  }
  return launchCount <= notificationPermissionLaunchLimit &&
      launchCount % notificationPermissionLaunchInterval == 1;
}

Future<void> ensureNotificationPermission(
  BuildContext context, {
  bool featuresNeedIt = false,
}) async {
  if (await hasNotificationPermission()) return;

  final pref = await SharedPreferences.getInstance();
  final snoozedMs = pref.getInt(keyNotificationPermissionSnoozedUntil);
  final now = DateTime.now();
  final ask = shouldPromptForNotifications(
    featuresNeedIt: featuresNeedIt,
    launchCount: pref.getInt(keyLaunchCountForNotificationPermission) ?? 0,
    now: now,
    snoozedUntil: snoozedMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(snoozedMs),
  );
  if (!ask || !context.mounted) return;

  final granted = await getNotificationPermission(context);
  if (!granted && featuresNeedIt) {
    await pref.setInt(
      keyNotificationPermissionSnoozedUntil,
      now.add(notificationPermissionSnooze).millisecondsSinceEpoch,
    );
  }
}

Future<bool> hasNotificationPermission() => Permission.notification.isGranted;

Future<bool> openNotificationSettings() => openAppSettings();

Future<bool> getNotificationPermission(BuildContext context) async {
  // Already granted
  if (await Permission.notification.isGranted) {
    return true;
  }

  // Only request on Android 13+ and iOS
  if (Platform.isAndroid || Platform.isIOS) {
    if (!context.mounted) return false;

    final bool? isAllowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
        ),
        title: Text(
          AppLocalizations.of(context)!.notifPermTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          AppLocalizations.of(context)!.notifPermContent,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.notifPermNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.notifPermEnable),
          ),
        ],
      ),
    );

    if (isAllowed ?? false) {
      final PermissionStatus status = await Permission.notification.request();
      // After two refusals Android stops showing its dialog and `request`
      // returns at once; the app's settings page is the only way left.
      if (status.isPermanentlyDenied) {
        await openNotificationSettings();
        return false;
      }
      return status == PermissionStatus.granted;
    }
  }

  return false;
}

// Call this to increment launch count
Future<void> incrementLaunchCount() async {
  final pref = await SharedPreferences.getInstance();
  final int count = pref.getInt(keyLaunchCountForNotificationPermission) ?? 0;
  await pref.setInt(keyLaunchCountForNotificationPermission, count + 1);
}
