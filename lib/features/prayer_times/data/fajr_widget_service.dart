import 'dart:ui';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../../challenge/data/challenge_local_data_source.dart';
import '../presentation/prayer_times_controller.dart';
import 'prayer_times_local_data_source.dart';
import 'prayer_times_repository.dart';

/// Refreshes the Android Fajr home-screen widget. Self-contained — no
/// BuildContext or provider instance needed, so it's safe to call from a
/// headless background isolate (`background_fetch`) as well as from the
/// running app.
///
/// Every call does a **live** prayer-times fetch (not a stale-cache read):
/// otherwise the widget would silently drift day-to-day if the app goes
/// unopened for a while (see the design doc's "Accepted tradeoff"). On
/// success it also reschedules the next Fajr-boundary background task, so
/// the refresh chain keeps going without the app running.
class FajrWidgetService {
  static const _androidProviderName = 'FajrWidgetProvider';
  static const _boundaryTaskId = 'com.subhwarrior.app.fajr_widget_boundary';

  static Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final challengeData = ChallengeLocalDataSource(prefs, uid: uid).load();

    // Never configured (onboarding not completed) — nothing to show yet.
    // Leave any previously-saved widget data untouched; the native side
    // treats "nothing ever saved" as the placeholder case.
    if (!challengeData.hasLocation) return;

    final settings = PrayerTimesLocalDataSource(prefs).load();
    final repository = PrayerTimesRepositoryImpl.fromPrefs(prefs);

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    try {
      final todayTimes = await repository.fetchByCoordinates(
        today,
        challengeData.userLatitude,
        challengeData.userLongitude,
        settings,
      );
      final tomorrowTimes = await repository.fetchByCoordinates(
        tomorrow,
        challengeData.userLatitude,
        challengeData.userLongitude,
        settings,
      );

      final todayFajr = _onDay(today, todayTimes.fajr);
      final tomorrowFajr = _onDay(tomorrow, tomorrowTimes.fajr);
      if (todayFajr == null) return;

      final now = DateTime.now();
      final remaining = PrayerTimeProvider.durationUntilNextFajr(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: now,
      );
      final progress = PrayerTimeProvider.fajrCycleProgress(
            todayFajrTime: todayFajr,
            tomorrowFajrTime: tomorrowFajr,
            now: now,
          ) ??
          0.0;
      final nextFajr = now.isBefore(todayFajr) ? todayFajr : tomorrowFajr;

      final l10n = await _loadL10n();
      final clockPattern = settings.use24HourFormat ? 'HH:mm' : 'hh:mm a';
      final clockPatternCompact = settings.use24HourFormat ? 'HH:mm' : 'hh:mm';
      final countdownText = remaining == null
          ? l10n.prayerCardCountdownUnknown
          : l10n.prayerCardCountdownValueWithSeconds(
              remaining.inHours,
              remaining.inMinutes % 60,
              remaining.inSeconds % 60,
            );

      final todaySunrise = _onDay(today, todayTimes.sunrise);
      final isWithinWindow = todaySunrise != null &&
          now.isAfter(todayFajr) &&
          now.isBefore(todaySunrise);

      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_title', l10n.prayerCardTitle);
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_is_within_window', isWithinWindow.toString());
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_time', DateFormat(clockPattern).format(todayFajr));
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_tomorrow_time',
          tomorrowFajr == null
              ? ''
              : DateFormat(clockPattern).format(tomorrowFajr));
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_countdown', countdownText);
      // Native side turns this into a live-ticking android.widget.Chronometer
      // (see FajrWidgetProvider.bindLiveCountdown) — Dart can't drive a
      // per-second UI update in a home-screen widget itself, but Android's
      // own Chronometer view can, entirely on-device.
      await HomeWidget.saveWidgetData<String>('fajr_widget_next_fajr_epoch_ms',
          nextFajr == null ? '' : nextFajr.millisecondsSinceEpoch.toString());
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_progress', (progress * 100).round().toString());
      await HomeWidget.saveWidgetData<String>('fajr_widget_sunrise',
          _formatCompact(todayTimes.sunrise, clockPatternCompact));
      await HomeWidget.saveWidgetData<String>('fajr_widget_dhuhr',
          _formatCompact(todayTimes.dhuhr, clockPatternCompact));
      await HomeWidget.saveWidgetData<String>('fajr_widget_asr',
          _formatCompact(todayTimes.asr, clockPatternCompact));
      await HomeWidget.saveWidgetData<String>('fajr_widget_maghrib',
          _formatCompact(todayTimes.maghrib, clockPatternCompact));
      await HomeWidget.saveWidgetData<String>('fajr_widget_isha',
          _formatCompact(todayTimes.isha, clockPatternCompact));
      await HomeWidget.updateWidget(androidName: _androidProviderName);

      if (nextFajr != null) {
        await _scheduleNextBoundary(nextFajr);
      }
    } catch (_) {
      // Offline or API error — leave previously-saved widget data as-is,
      // same offline-tolerant contract as PrayerTimeProvider._runFetch.
    }
  }

  static Future<void> _scheduleNextBoundary(DateTime nextFajr) async {
    final delayMs = nextFajr.difference(DateTime.now()).inMilliseconds;
    if (delayMs <= 0) return;
    await BackgroundFetch.scheduleTask(TaskConfig(
      taskId: _boundaryTaskId,
      delay: delayMs,
      forceAlarmManager: true,
      enableHeadless: true,
    ));
  }

  /// Same lookup NotificationService._loadL10n uses: honours the user's
  /// in-app language choice, falling back to the device locale (or English
  /// when unsupported). Duplicated rather than shared because that method
  /// is private to notification_service.dart — small enough to not be
  /// worth a shared-utility extraction.
  static Future<AppLocalizations> _loadL10n() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(LocaleProvider.prefsKey);
    var locale =
        stored != null ? Locale(stored) : PlatformDispatcher.instance.locale;
    if (!AppLocalizations.delegate.isSupported(locale)) {
      locale = const Locale('en');
    }
    return lookupAppLocalizations(locale);
  }

  /// Formats a raw "HH:mm" prayer-time string using [pattern], mirroring
  /// PrayerTimeProvider.formatTimeStringCompact. Returns the input
  /// unchanged if it can't be parsed.
  static String _formatCompact(String hhmm, String pattern) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return hhmm;
    return DateFormat(pattern).format(DateTime(2000, 1, 1, h, m));
  }

  /// Builds a [DateTime] on [day]'s calendar date from an "HH:mm" string.
  /// Same parsing PrayerTimeProvider._onDay uses.
  static DateTime? _onDay(DateTime day, String timeStr) {
    try {
      final parts = timeStr.split(':');
      return DateTime(day.year, day.month, day.day, int.parse(parts[0]),
          int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }
}
