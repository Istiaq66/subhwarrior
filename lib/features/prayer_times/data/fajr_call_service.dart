import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_standalone.dart';
import 'package:timezone/timezone.dart' as tz;

/// Rings the device like an alarm at Fajr, instead of posting a notification
/// the user can sleep through.
///
/// The ring is a notification scheduled as an alarm clock: when it fires, the
/// system posts it, plays [_ringtone] on the alarm stream until it is answered
/// or [_ringDuration] passes, and raises the call screen through its
/// full-screen intent. No Dart runs at Fajr. An earlier version woke a
/// background isolate through android_alarm_manager_plus, which hands the
/// alarm to JobScheduler; vivo (and other OEM builds) hold those jobs while
/// the app is closed, so the call only rang once the user opened the app.
///
/// Android only. iOS reaches a call screen exclusively through a PushKit VoIP
/// push sent by a server, so every entry point here no-ops off Android rather
/// than pretending to schedule something.
class FajrCallService {
  FajrCallService._();

  /// Who the call appears to be from. Deliberately not localized: it is a name.
  static const callerName = 'Namaz';

  /// Fixed id so rescheduling replaces rather than stacks.
  static const notificationId = 20250928;

  /// Marks the call's notification. `MainActivity.kt` matches it as well, to
  /// raise the call screen over the lock screen before Flutter has booted.
  static const payload = 'fajr_call';

  static const acceptActionId = 'fajr_call_accept';
  static const declineActionId = 'fajr_call_decline';

  /// A channel's sound and audio usage are fixed when it is first created, so
  /// changing either needs a new id.
  static const _channelId = 'fajr_call_alarm';

  /// `res/raw/bird_sound.wav`, kept from resource shrinking by `raw/keep.xml`.
  static const _ringtone = 'bird_sound';

  /// How long the call rings before it gives up. Long enough to wake someone,
  /// short enough not to wake the street.
  static const _ringDuration = Duration(seconds: 45);

  /// `Notification.FLAG_INSISTENT`: repeat the sound until the notification
  /// is cancelled, instead of playing it once.
  static const _flagInsistent = 4;

  /// How often the open call screen checks the notification is still up, so
  /// it closes when the ring times out or is dismissed from the shade.
  static const _ringingPollInterval = Duration(seconds: 2);

  static const _channel = MethodChannel('com.subhwarrior.app/fajr_call');

  static final _ringing = ValueNotifier<bool>(false);
  static Timer? _ringingWatch;

  /// Whether the in-app call screen should be showing.
  static ValueListenable<bool> get ringing => _ringing;

  /// `Platform.isAndroid` rather than [defaultTargetPlatform]: the latter
  /// reports Android under `flutter_test` on any host, which would send every
  /// widget test into a plugin channel that is not there.
  static bool get _isSupported => !kIsWeb && Platform.isAndroid;

  static FlutterLocalNotificationsPlugin get _plugin =>
      FlutterLocalNotificationsPlugin();

  /// The next time Fajr comes round, given today's [fajrTime].
  ///
  /// Tomorrow's Fajr shifts by a minute or two from today's; a day's offset is
  /// close enough to schedule against and is corrected on the next refresh,
  /// which is also how the Fajr reminder notification handles the rollover.
  static DateTime nextOccurrence({required DateTime fajrTime, DateTime? now}) {
    final current = now ?? DateTime.now();
    return fajrTime.isAfter(current)
        ? fajrTime
        : fajrTime.add(const Duration(days: 1));
  }

  /// Schedules the call for [fajrTime] and the same time every day after, or
  /// cancels it when [enabled] is false or no Fajr time is known yet.
  ///
  /// The daily repeat is the plugin's, natively, so the call keeps ringing
  /// while the app stays closed. It drifts by the minute or two Fajr moves
  /// each day until the next app launch or background refresh reschedules it.
  ///
  /// A past [fajrTime] is skipped rather than fired immediately — the caller
  /// reschedules from tomorrow's time.
  static Future<void> schedule({
    required bool enabled,
    required DateTime? fajrTime,
    DateTime? now,
  }) async {
    if (!_isSupported) return;

    if (!enabled || fajrTime == null) {
      await cancel();
      return;
    }

    final at = fajrTime;
    if (!at.isAfter(now ?? DateTime.now())) {
      debugPrint('FajrCallService: $at already passed — not scheduling.');
      await cancel();
      return;
    }

    // `alarmClock` is an exact alarm, refused without the permission. Settings
    // reschedules on resume once the user grants it.
    if (!await canScheduleExactAlarms()) {
      debugPrint(
        'FajrCallService: exact alarms not allowed — call for $at not scheduled',
      );
      return;
    }

    final l10n = await loadStoredL10n();
    await _plugin.zonedSchedule(
      notificationId,
      callerName,
      l10n.notifFajrBody,
      tz.TZDateTime.from(at, tz.local),
      NotificationDetails(android: _details(l10n)),
      // Alarm-clock alarms are exempt from Doze and from app standby, and
      // fire at the exact minute.
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
    debugPrint('FajrCallService: call scheduled for $at, then daily');
  }

  static AndroidNotificationDetails _details(AppLocalizations l10n) {
    return AndroidNotificationDetails(
      _channelId,
      l10n.fajrCallChannelName,
      channelDescription: l10n.settingsFajrCallSubtitle,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      sound: const RawResourceAndroidNotificationSound(_ringtone),
      // The alarm stream rings through silent mode, like the clock app does.
      audioAttributesUsage: AudioAttributesUsage.alarm,
      vibrationPattern: Int64List.fromList([0, 800, 600, 800]),
      additionalFlags: Int32List.fromList([_flagInsistent]),
      timeoutAfter: _ringDuration.inMilliseconds,
      ongoing: true,
      autoCancel: false,
      color: const Color(0xFF0F5233),
      actions: [
        // Both only take down the posted notification, natively; the daily
        // schedule stays.
        AndroidNotificationAction(declineActionId, l10n.fajrCallDecline),
        AndroidNotificationAction(
          acceptActionId,
          l10n.fajrCallAccept,
          showsUserInterface: true,
        ),
      ],
    );
  }

  /// Whether the OS will let the call take over the screen.
  ///
  /// Android 14 put full-screen intents behind a second gate: the manifest
  /// permission is granted, but `canUseFullScreenIntent` is false by default
  /// for anything the platform does not consider a calling or alarm app.
  /// Without it the call is a heads-up notification — it still rings, but
  /// the call screen does not take over a locked phone.
  static Future<bool> canShowFullScreen() async {
    if (!_isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('canUseFullScreenIntent') ??
          false;
    } catch (e) {
      debugPrint('FajrCallService: full-screen check failed: $e');
      return false;
    }
  }

  /// Whether the OS will run the call's alarm at the exact Fajr minute.
  ///
  /// Android 12+ puts exact alarms (`setAlarmClock` included) behind
  /// SCHEDULE_EXACT_ALARM, which Android 14 no longer grants at install; the
  /// user allows it under "Alarms & reminders". Older versions always allow
  /// it. If the check itself fails, assume allowed and let scheduling try.
  static Future<bool> canScheduleExactAlarms() async {
    if (!_isSupported) return false;
    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (e) {
      debugPrint('FajrCallService: exact-alarm check failed: $e');
      return true;
    }
  }

  /// Opens the system "Alarms & reminders" page for this app.
  static Future<void> requestExactAlarmAccess() async {
    if (!_isSupported) return;
    try {
      await Permission.scheduleExactAlarm.request();
    } catch (e) {
      debugPrint('FajrCallService: exact-alarm request failed: $e');
    }
  }

  /// Opens the system page where full-screen notifications are allowed.
  static Future<void> requestFullScreenAccess() async {
    if (!_isSupported) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestFullScreenIntentPermission();
    } catch (e) {
      debugPrint('FajrCallService: full-screen request failed: $e');
    }
  }

  /// Drops the scheduled call, and any ring in progress.
  static Future<void> cancel() async {
    if (!_isSupported) return;
    _stopWatching();
    await _plugin.cancel(notificationId);
  }

  /// Picks up a call that launched the app from cold: the full-screen intent
  /// at Fajr, a tap on the notification, or its answer button.
  ///
  /// Run before the first frame, so the call screen is not held back behind
  /// Firebase and sign-in at boot.
  static Future<void> restoreFromLaunch() async {
    if (!_isSupported) return;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      final response = details?.notificationResponse;
      if ((details?.didNotificationLaunchApp ?? false) && response != null) {
        handleResponse(response);
      }
    } catch (e) {
      debugPrint('FajrCallService: launch check failed: $e');
    }
  }

  /// Routes a response to the call's notification while the app is running.
  /// Returns false for any other notification.
  static bool handleResponse(NotificationResponse response) {
    if (!_isSupported || response.payload != payload) return false;
    switch (response.actionId) {
      case acceptActionId:
        unawaited(answer());
      case declineActionId:
        unawaited(dismiss());
      default:
        // The full-screen intent or a tap on the notification body.
        unawaited(_showWhileRinging());
    }
    return true;
  }

  /// Stops the ring and leaves the user in the app, asking them to unlock.
  static Future<void> answer() => _endCall(unlock: true);

  /// Stops the ring and sends the app to the background.
  static Future<void> dismiss() => _endCall(unlock: false);

  static Future<void> _endCall({required bool unlock}) async {
    _stopWatching();
    try {
      await _channel.invokeMethod<void>('endCall', {
        'notificationId': notificationId,
        'unlock': unlock,
      });
    } catch (e) {
      debugPrint('FajrCallService: could not end the call: $e');
    }
  }

  /// Shows the call screen for as long as the ring lasts. A launch that
  /// arrives after the ring timed out drops the lock-screen override instead,
  /// so the app does not sit over the keyguard.
  static Future<void> _showWhileRinging() async {
    if (!await _isRinging()) {
      await _releaseLockScreen();
      return;
    }
    _ringing.value = true;
    _ringingWatch?.cancel();
    _ringingWatch = Timer.periodic(_ringingPollInterval, (_) async {
      if (await _isRinging()) return;
      _stopWatching();
      await _releaseLockScreen();
    });
  }

  static void _stopWatching() {
    _ringingWatch?.cancel();
    _ringingWatch = null;
    _ringing.value = false;
  }

  static Future<bool> _isRinging() async {
    try {
      final active = await _plugin.getActiveNotifications();
      return active.any((n) => n.id == notificationId);
    } catch (e) {
      debugPrint('FajrCallService: active notification check failed: $e');
      return false;
    }
  }

  static Future<void> _releaseLockScreen() async {
    try {
      await _channel.invokeMethod<void>('releaseLockScreen');
    } catch (e) {
      debugPrint('FajrCallService: could not release the lock screen: $e');
    }
  }
}
