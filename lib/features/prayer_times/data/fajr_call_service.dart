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

  /// Books the next day's call from the background isolate.
  ///
  /// The stored instant is the one that just rang, so the next is a day later;
  /// the app corrects it to the real Fajr time on its next launch, when actual
  /// prayer times are available. Drifting by the minute-or-two Fajr moves in a
  /// day beats not ringing at all.
  static Future<void> rescheduleNextFromAlarm(SharedPreferences prefs) async {
    if (!_isSupported) return;

    final lastMs = prefs.getInt(_prefsNextFajrKey);
    if (lastMs == null) return;

    final next = nextOccurrence(
      fajrTime: DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
    await schedule(enabled: true, fajrTime: next);
  }

  /// Whether the OS will let the call take over the screen.
  ///
  /// Android 14 put full-screen intents behind a second gate: the manifest
  /// permission is granted, but `canUseFullScreenIntent` is false by default
  /// for anything the platform does not consider a calling or alarm app.
  /// Without it the call posts a plain notification instead of the call
  /// screen, with the generic notification sound rather than the ringtone.
  static Future<bool> canShowFullScreen() async {
    if (!_isSupported) return false;
    try {
      return await FlutterCallkitIncoming.canUseFullScreenIntent();
    } catch (e) {
      debugPrint('FajrCallService: full-screen check failed: $e');
      return false;
    }
  }

  /// Opens the system page where full-screen notifications are allowed.
  static Future<void> requestFullScreenAccess() async {
    if (!_isSupported) return;
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    } catch (e) {
      debugPrint('FajrCallService: full-screen request failed: $e');
    }
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
        isShowFullLockedScreen: true,
        isImportant: true,
        // Deliberately false. `isFullScreen: true` makes the plugin launch its
        // call activity directly (CallkitIncomingBroadcastReceiver), a path
        // that never starts the ringtone — the activity only keeps an already
        // playing one alive — and that Android blocks outright when the app
        // process is dead. False takes the notification path instead, which
        // plays [ringtonePath] and carries a full-screen intent, so the call
        // still owns the lock screen wherever the OS permits it.
        isFullScreen: false,
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
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (e) {
      debugPrint('FajrCallService: could not end the call: $e');
    }
  }

  /// Clears a call left hanging from a previous launch.
  ///
  /// Answering from a dead app starts the process fresh, and [listenForAnswers]
  /// is only registered once boot reaches its first frame — too late to catch
  /// that accept. The plugin meanwhile promotes the call to "ongoing", with a
  /// foreground service and a Hang Up notification that nothing ever
  /// dismisses. The app being open means the alarm did its job, so any call
  /// still standing at startup is stale by definition.
  static Future<void> clearLingeringCalls() => endCall();

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
  debugPrint('FajrCallService: alarm fired');

  // The isolate has its own copy of the preference cache.
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  if (!(prefs.getBool(FajrCallService._prefsEnabledKey) ?? false)) {
    debugPrint('FajrCallService: call disabled since it was scheduled.');
    return;
  }

  try {
    await FajrCallService.ring();
    debugPrint('FajrCallService: call screen requested');
  } catch (e) {
    // A failure here is invisible otherwise — the isolate has no UI.
    debugPrint('FajrCallService: could not show the call: $e');
  }

  // `oneShotAt` fires once. Nothing else re-arms it while the app stays
  // closed, so tomorrow's call has to be booked from here — otherwise the
  // alarm rings exactly once and then only ever comes back if the user opens
  // the app.
  await FajrCallService.rescheduleNextFromAlarm(prefs);
}
