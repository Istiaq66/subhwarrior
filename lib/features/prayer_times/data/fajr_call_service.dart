import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_alarm_call/flutter_alarm_call.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:subh_warrior/core/l10n/l10n_standalone.dart';

/// Rings the device like a call at Fajr, instead of posting a notification
/// the user can sleep through.
///
/// The ringing, the call screen and the lock-screen handling are
/// flutter_alarm_call's: an alarm-clock notification that needs no Dart at
/// Fajr, so OEM battery managers cannot hold it back (see that package). This
/// class keeps what is Fajr about it — the caller, the strings, the sound —
/// and the app's switch-driven scheduling.
///
/// Android only; the package no-ops elsewhere.
class FajrCallService {
  FajrCallService._();

  /// Who the call appears to be from. Deliberately not localized: it is a name.
  static const callerName = 'Namaz';

  /// Fixed id so rescheduling replaces rather than stacks.
  static const notificationId = 20250928;

  /// The channel the call has rung on since before the package; keeping its
  /// id keeps any sound or importance the user set for it.
  static const _channelId = 'fajr_call_alarm';

  /// `res/raw/bird_sound.wav`, kept from resource shrinking by `raw/keep.xml`.
  static const _ringtone = 'bird_sound';

  /// The next time Fajr comes round, given today's [fajrTime].
  ///
  /// Tomorrow's Fajr shifts by a minute or two from today's; a day's offset is
  /// close enough to schedule against and is corrected on the next refresh,
  /// which is also how the Fajr reminder notification handles the rollover.
  static DateTime nextOccurrence({required DateTime fajrTime, DateTime? now}) =>
      FlutterAlarmCall.nextOccurrence(fajrTime, now: now);

  /// Schedules the call for [fajrTime] and the same time every day after, or
  /// cancels it when [enabled] is false or no Fajr time is known yet.
  ///
  /// The daily repeat drifts by the minute or two Fajr moves each day until
  /// the next app launch or background refresh reschedules it.
  ///
  /// A past [fajrTime] is skipped rather than fired immediately — the caller
  /// reschedules from tomorrow's time.
  static Future<void> schedule({
    required bool enabled,
    required DateTime? fajrTime,
    DateTime? now,
  }) async {
    if (!enabled || fajrTime == null) {
      await cancel();
      return;
    }

    if (!fajrTime.isAfter(now ?? DateTime.now())) {
      debugPrint('FajrCallService: $fajrTime already passed — not scheduling.');
      await cancel();
      return;
    }

    // `Platform.isAndroid`, not `defaultTargetPlatform`: the latter reports
    // Android under `flutter_test`. The package no-ops off Android anyway;
    // this skips loading strings for a call that cannot ring.
    if (kIsWeb || !Platform.isAndroid) return;

    final l10n = await loadStoredL10n();
    final scheduled = await FlutterAlarmCall.schedule(
      AlarmCall(
        id: notificationId,
        callerName: callerName,
        body: l10n.notifFajrBody,
        time: fajrTime,
        repeatDaily: true,
        answerLabel: l10n.fajrCallAccept,
        dismissLabel: l10n.fajrCallDecline,
        channel: AlarmCallChannel(
          id: _channelId,
          name: l10n.fajrCallChannelName,
          description: l10n.settingsFajrCallSubtitle,
          rawSound: _ringtone,
        ),
      ),
      now: now,
    );
    // Not scheduled means exact alarms are refused (or this is not Android);
    // Settings says so and reschedules on resume once they are allowed.
    debugPrint(
      scheduled
          ? 'FajrCallService: call scheduled for $fajrTime, then daily'
          : 'FajrCallService: call for $fajrTime not scheduled',
    );
  }

  /// Whether the OS will let the call take over the screen. Without it the
  /// call is a heads-up notification — it still rings, but does not take
  /// over a locked phone.
  static Future<bool> canShowFullScreen() =>
      FlutterAlarmCall.canUseFullScreenIntent();

  /// Whether the OS will ring the call at the exact Fajr minute ("Alarms &
  /// reminders", which Android 14 no longer grants at install).
  static Future<bool> canScheduleExactAlarms() =>
      FlutterAlarmCall.canScheduleExactAlarms();

  /// Opens the system "Alarms & reminders" page for this app.
  static Future<void> requestExactAlarmAccess() =>
      FlutterAlarmCall.requestExactAlarmPermission();

  /// Opens the system page where full-screen notifications are allowed.
  static Future<void> requestFullScreenAccess() =>
      FlutterAlarmCall.requestFullScreenIntentPermission();

  /// Drops the scheduled call, and any ring in progress.
  static Future<void> cancel() => FlutterAlarmCall.cancel(notificationId);

  /// Picks up a call that launched the app from cold. Run before the first
  /// frame, so the call screen is not held back behind boot.
  static Future<void> restoreFromLaunch() async {
    try {
      await FlutterAlarmCall.restoreFromLaunch();
    } catch (e) {
      debugPrint('FajrCallService: launch check failed: $e');
    }
  }

  /// Routes a response to the call's notification while the app is running.
  /// Returns false for any other notification.
  static bool handleResponse(NotificationResponse response) =>
      FlutterAlarmCall.handleNotificationResponse(response);
}
