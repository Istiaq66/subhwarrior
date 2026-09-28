import 'dart:async';
import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/l10n/l10n_standalone.dart';

/// Rings the device like an incoming call at Fajr, instead of posting a
/// notification the user can sleep through.
///
/// Android only. iOS reaches CallKit exclusively through a PushKit VoIP push
/// sent by a server — an app cannot raise its own call screen from a local
/// timer — so every entry point here no-ops off Android rather than pretending
/// to schedule something.
class FajrCallService {
  FajrCallService._();

  /// Who the call appears to be from. Deliberately not localized: it is a name.
  static const callerName = 'Namaz';

  /// Fixed id for the alarm so rescheduling replaces rather than stacks.
  static const _alarmId = 20250928;

  /// Where the next Fajr instant is parked for the background isolate, which
  /// has no access to the app's providers.
  static const _prefsNextFajrKey = 'fajr_call_next_epoch_ms';

  /// Whether the user still wants the call — the background isolate re-reads
  /// this so a toggle in settings takes effect even while the app is dead.
  static const _prefsEnabledKey = 'fajr_call_enabled';

  /// How long the call screen rings before it gives up and leaves a missed
  /// call. Long enough to wake someone, short enough not to wake the street.
  static const _ringDuration = Duration(seconds: 45);

  /// `Platform.isAndroid` rather than [defaultTargetPlatform]: the latter
  /// reports Android under `flutter_test` on any host, which would send every
  /// widget test into a plugin channel that is not there.
  static bool get _isSupported => !kIsWeb && Platform.isAndroid;

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

  /// Prepares the alarm plugin. Safe to call more than once.
  static Future<void> initialize() async {
    if (!_isSupported) return;
    await AndroidAlarmManager.initialize();
  }

  /// Schedules the call for [fajrTime], or cancels it when [enabled] is false
  /// or no Fajr time is known yet.
  ///
  /// A past [fajrTime] is skipped rather than fired immediately — the caller
  /// reschedules from tomorrow's time.
  static Future<void> schedule({
    required bool enabled,
    required DateTime? fajrTime,
    DateTime? now,
  }) async {
    if (!_isSupported) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsEnabledKey, enabled);

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

    await prefs.setInt(_prefsNextFajrKey, at.millisecondsSinceEpoch);

    // `exact` + `wakeup` because a prayer time is the whole point; `rescheduleOnReboot`
    // so a phone restarted overnight still rings.
    final scheduled = await AndroidAlarmManager.oneShotAt(
      at,
      _alarmId,
      onFajrAlarm,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
    debugPrint(
      scheduled
          ? 'FajrCallService: call scheduled for $at'
          : 'FajrCallService: could not schedule the call for $at',
    );
  }

  /// Drops any pending call alarm.
  static Future<void> cancel() async {
    if (!_isSupported) return;
    await AndroidAlarmManager.cancel(_alarmId);
  }

  /// Shows the incoming-call screen now.
  ///
  /// The call screen is raised from a background isolate, so its labels come
  /// from the stored locale rather than a `BuildContext`. [callerName] is the
  /// one string left untranslated — it is a name.
  static Future<void> ring({String? handle}) async {
    if (!_isSupported) return;

    final l10n = await loadStoredL10n();
    final params = CallKitParams(
      id: _alarmId.toString(),
      nameCaller: callerName,
      appName: 'Subh Warrior',
      handle: handle ?? callerName,
      type: 0,
      duration: _ringDuration.inMilliseconds,
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: l10n.fajrCallMissed,
      ),
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        // The point of a call over a notification: it takes the whole locked
        // screen and rings past Do Not Disturb's notification tier.
        isShowFullLockedScreen: true,
        isImportant: true,
        isFullScreen: true,
        textAccept: l10n.fajrCallAccept,
        textDecline: l10n.fajrCallDecline,
        ringtonePath: 'bird_sound',
        backgroundColor: '#0F5233',
        actionColor: '#339C6B',
        textColor: '#FFFFFF',
        incomingCallNotificationChannelName: l10n.fajrCallChannelName,
        missedCallNotificationChannelName: l10n.fajrCallMissedChannelName,
        isShowCallID: false,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Ends the ringing call, if one is up.
  static Future<void> endCall() async {
    if (!_isSupported) return;
    await FlutterCallkitIncoming.endAllCalls();
  }

  /// Clears the call screen once the user has answered or dismissed it.
  ///
  /// Accepting already brings the app forward, which is the whole point of the
  /// call — there is no audio session to keep alive, so the call is ended
  /// either way and the user lands on whatever screen boot routes them to.
  static StreamSubscription<CallEvent?>? listenForAnswers() {
    if (!_isSupported) return null;

    return FlutterCallkitIncoming.onEvent.listen((event) async {
      switch (event) {
        case CallEventActionCallAccept():
        case CallEventActionCallDecline():
        case CallEventActionCallTimeout():
        case CallEventActionCallEnded():
          await endCall();
        default:
          break;
      }
    });
  }
}

/// Fires in a background isolate at Fajr — no widget tree, no providers, so
/// everything it needs was parked in `SharedPreferences` when the alarm was
/// set.
///
/// Must stay a top-level function annotated `vm:entry-point`: the Android side
/// looks it up by handle after spinning up a fresh Dart VM.
@pragma('vm:entry-point')
Future<void> onFajrAlarm() async {
  // The isolate has its own copy of the preference cache.
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  if (!(prefs.getBool(FajrCallService._prefsEnabledKey) ?? false)) {
    debugPrint('FajrCallService: call disabled since it was scheduled.');
    return;
  }

  await FajrCallService.ring();
}
