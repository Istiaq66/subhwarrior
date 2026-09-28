/// One recorded trace (used by [FakePerformanceService] assertions).
typedef RecordedTrace = ({String name, Map<String, int> metrics});

/// Trace names are wire format — never rename without a dashboard decision.
abstract final class PerformanceTraces {
  PerformanceTraces._();

  static const appStartup = 'app_startup';
}

/// Performance-monitoring abstraction so widgets and controllers never import
/// Firebase directly and tests can assert on traces via
/// [FakePerformanceService].
abstract class PerformanceService {
  /// Records a completed trace called [name] carrying [metrics].
  ///
  /// Metrics are integers because that is all a Firebase Performance custom
  /// metric holds. A trace recorded this way cannot be backdated, so its own
  /// duration is meaningless — the timings that matter ride as metrics.
  Future<void> recordTrace(String name, Map<String, int> metrics);

  /// Set once at startup; lets context-free call sites record traces.
  /// Null in tests unless set.
  static PerformanceService? maybeInstance;
}

/// In-memory implementation for tests.
class FakePerformanceService implements PerformanceService {
  final List<RecordedTrace> traces = [];

  @override
  Future<void> recordTrace(String name, Map<String, int> metrics) async {
    traces.add((name: name, metrics: metrics));
  }
}
