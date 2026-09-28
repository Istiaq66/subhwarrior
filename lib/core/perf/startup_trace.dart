import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/perf/performance_service.dart';

/// Milestones on the path from process start to a usable Home screen.
///
/// Names are wire format — they ship as analytics parameters, so renaming one
/// splits the metric in the dashboard.
abstract final class StartupMarks {
  StartupMarks._();

  /// `SharedPreferences` is ready; `runApp` is about to be called.
  static const prefsLoaded = 'prefs_loaded';

  /// The splash screen has been rasterized — the first pixels the user sees.
  static const firstFrame = 'first_frame';

  /// `Firebase.initializeApp` returned.
  static const firebaseReady = 'firebase_ready';

  /// A uid exists (anonymous sign-in included).
  static const authReady = 'auth_ready';

  /// Boot finished waiting on the prayer-times refresh budget.
  static const prayerTimesSettled = 'prayer_times_settled';

  /// Boot is done and the real router replaces the splash.
  static const bootComplete = 'boot_complete';
}

/// Records how long startup takes, milestone by milestone.
///
/// Four consumers, one set of marks: `debugPrint` for a local run, a
/// `dart:developer` timeline task so the phases show up as a slice in DevTools
/// and `flutter run --trace-startup`, one analytics event per launch, and a
/// Firebase Performance trace — the last two are what make a regression
/// visible on real devices rather than only on a desk.
///
/// Every mark is milliseconds since [start], so the numbers stay comparable
/// across launches and devices. Instrumentation must never be the reason
/// startup fails: marks are cheap integer writes, and [finish] swallows a
/// failed analytics call.
abstract final class StartupTrace {
  StartupTrace._();

  static final Stopwatch _watch = Stopwatch();
  static final Map<String, int> _marks = <String, int>{};
  static developer.TimelineTask? _task;
  static bool _finished = false;

  /// Marks recorded so far, in the order they happened.
  @visibleForTesting
  static Map<String, int> get marks => Map.unmodifiable(_marks);

  /// Whether [finish] has already reported this launch.
  @visibleForTesting
  static bool get isFinished => _finished;

  /// Begins the trace. Call as early in `main` as the binding allows.
  static void start() {
    if (_watch.isRunning) return;
    _watch.start();
    _task = developer.TimelineTask()..start('app_startup');
  }

  /// Records [name] at the current elapsed time, keeping the first value if it
  /// somehow fires twice (a boot retry re-runs the same code paths).
  static void mark(String name) {
    if (!_watch.isRunning || _finished || _marks.containsKey(name)) return;

    final elapsedMs = _watch.elapsedMilliseconds;
    _marks[name] = elapsedMs;
    _task?.instant(name, arguments: {'elapsed_ms': elapsedMs});

    if (!kReleaseMode) {
      debugPrint('[startup] $name: ${elapsedMs}ms');
    }
  }

  /// Closes the trace and reports it once per launch.
  ///
  /// Both reporters are optional so a boot that never reached Firebase still
  /// prints its timings locally.
  static Future<void> finish({
    AnalyticsService? analytics,
    PerformanceService? performance,
  }) async {
    if (!_watch.isRunning || _finished) return;

    mark(StartupMarks.bootComplete);
    _finished = true;
    final totalMs = _watch.elapsedMilliseconds;
    _watch.stop();
    _task?.finish();
    _task = null;

    if (!kReleaseMode) {
      debugPrint('[startup] total: ${totalMs}ms');
    }

    final metrics = {
      for (final entry in _marks.entries) '${entry.key}_ms': entry.value,
      'total_ms': totalMs,
    };

    // Reported independently: one backend being unreachable should not cost
    // the other its data point, and neither is worth a failed boot.
    await Future.wait([
      _report(() async {
        final reporter = analytics ?? AnalyticsService.maybeInstance;
        await reporter?.logEvent(AnalyticsEvents.appStartup, metrics);
      }),
      _report(() async {
        final reporter = performance ?? PerformanceService.maybeInstance;
        await reporter?.recordTrace(PerformanceTraces.appStartup, metrics);
      }),
    ]);
  }

  static Future<void> _report(Future<void> Function() send) async {
    try {
      await send();
    } catch (error) {
      // A dropped metric is not worth a failed boot, but it should not vanish
      // without trace on a development run either.
      if (!kReleaseMode) {
        debugPrint('[startup] report failed: $error');
      }
    }
  }

  /// Drops all state so one test cannot see another's marks.
  @visibleForTesting
  static void resetForTest() {
    _watch
      ..stop()
      ..reset();
    _marks.clear();
    _task = null;
    _finished = false;
  }
}
