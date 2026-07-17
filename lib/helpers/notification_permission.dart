import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';

const int notificationPermissionLaunchLimit = 31;
const int notificationPermissionLaunchInterval = 10;
const String keyLaunchCountForNotificationPermission =
    'launch_count_notification_permission';

Future<void> ensureNotificationPermission(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();
  final int launchCount =
      pref.getInt(keyLaunchCountForNotificationPermission) ?? 0;

  if (launchCount <= notificationPermissionLaunchLimit &&
      launchCount % notificationPermissionLaunchInterval == 1) {
    if (!context.mounted) return;
    await getNotificationPermission(context);
  }
}

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
