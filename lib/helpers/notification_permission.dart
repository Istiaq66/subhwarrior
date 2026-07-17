import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int notificationPermissionLaunchLimit = 31;
const int notificationPermissionLaunchInterval = 10;
const String keyLaunchCountForNotificationPermission =
    'launch_count_notification_permission';

Future<void> ensureNotificationPermission(BuildContext context) async {
  var pref = await SharedPreferences.getInstance();
  int launchCount = pref.getInt(keyLaunchCountForNotificationPermission) ?? 0;

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

    bool? isAllowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Enable Notifications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Get reminded about Fajr prayer and daily logging to stay on track with your Subh Warrior challenge.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (isAllowed ?? false) {
      PermissionStatus status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    }
  }

  return false;
}

// Call this to increment launch count
Future<void> incrementLaunchCount() async {
  var pref = await SharedPreferences.getInstance();
  int count = pref.getInt(keyLaunchCountForNotificationPermission) ?? 0;
  await pref.setInt(keyLaunchCountForNotificationPermission, count + 1);
}
