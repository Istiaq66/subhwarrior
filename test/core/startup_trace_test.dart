import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/perf/performance_service.dart';
import 'package:subh_warrior/core/perf/startup_trace.dart';

void main() {
  setUp(StartupTrace.resetForTest);
  tearDown(StartupTrace.resetForTest);

  test('marks are recorded once the trace has started', () {
    StartupTrace.start();
    StartupTrace.mark(StartupMarks.prefsLoaded);
    StartupTrace.mark(StartupMarks.firstFrame);

    expect(
      StartupTrace.marks.keys,
      [StartupMarks.prefsLoaded, StartupMarks.firstFrame],
    );
    expect(StartupTrace.marks.values, everyElement(greaterThanOrEqualTo(0)));
  });

  test('a mark before start is dropped rather than timed from zero', () {
    StartupTrace.mark(StartupMarks.prefsLoaded);

    expect(StartupTrace.marks, isEmpty);
  });

  test('a repeated mark keeps the first timing', () {
    StartupTrace.start();
    StartupTrace.mark(StartupMarks.firstFrame);
    final first = StartupTrace.marks[StartupMarks.firstFrame];

    StartupTrace.mark(StartupMarks.firstFrame);

    expect(StartupTrace.marks[StartupMarks.firstFrame], first);
  });

  test('finish reports every mark plus the total, once per launch', () async {
    final analytics = FakeAnalyticsService();
    StartupTrace.start();
    StartupTrace.mark(StartupMarks.prefsLoaded);

    await StartupTrace.finish(analytics: analytics);
    await StartupTrace.finish(analytics: analytics);

    expect(analytics.events, hasLength(1));
    final event = analytics.events.single;
    expect(event.name, AnalyticsEvents.appStartup);
    expect(
      event.parameters?.keys,
      containsAll([
        '${StartupMarks.prefsLoaded}_ms',
        '${StartupMarks.bootComplete}_ms',
        'total_ms',
      ]),
    );
    expect(event.parameters?.values, everyElement(isA<int>()));
    expect(StartupTrace.isFinished, isTrue);
  });

  test('finish records the same metrics as a performance trace', () async {
    final performance = FakePerformanceService();
    StartupTrace.start();
    StartupTrace.mark(StartupMarks.firebaseReady);

    await StartupTrace.finish(performance: performance);

    expect(performance.traces, hasLength(1));
    final trace = performance.traces.single;
    expect(trace.name, PerformanceTraces.appStartup);
    expect(
      trace.metrics.keys,
      containsAll([
        '${StartupMarks.firebaseReady}_ms',
        '${StartupMarks.bootComplete}_ms',
        'total_ms',
      ]),
    );
  });

  test('one failing reporter does not cost the other its data', () async {
    final performance = FakePerformanceService();
    StartupTrace.start();

    await StartupTrace.finish(
      analytics: _ThrowingAnalyticsService(),
      performance: performance,
    );

    expect(performance.traces, hasLength(1));
  });

  test('a mark after finish does not reopen the trace', () async {
    final analytics = FakeAnalyticsService();
    StartupTrace.start();
    await StartupTrace.finish(analytics: analytics);

    StartupTrace.mark(StartupMarks.firstFrame);

    expect(StartupTrace.marks, isNot(contains(StartupMarks.firstFrame)));
  });

  test('a boot that never reached Firebase still closes cleanly', () async {
    StartupTrace.start();
    StartupTrace.mark(StartupMarks.prefsLoaded);

    await StartupTrace.finish();

    expect(StartupTrace.isFinished, isTrue);
    expect(StartupTrace.marks, contains(StartupMarks.bootComplete));
  });

  test('a failing analytics call does not throw out of finish', () async {
    StartupTrace.start();

    await expectLater(
      StartupTrace.finish(analytics: _ThrowingAnalyticsService()),
      completes,
    );
  });
}

class _ThrowingAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    throw StateError('analytics is down');
  }
}
