import 'package:firebase_performance/firebase_performance.dart';

import 'performance_service.dart';

/// Production implementation backed by Firebase Performance Monitoring.
///
/// The SDK also records its own automatic traces — app start, foreground and
/// background, screen rendering — without any call from here. This adds the
/// Dart-side breakdown the platform cannot see: which part of boot the time
/// went to.
class FirebasePerformanceService implements PerformanceService {
  FirebasePerformanceService([FirebasePerformance? performance])
      : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;

  /// Turns data collection on explicitly, rather than relying on the
  /// manifest/plist default — which a `firebase_performance_collection_enabled`
  /// flag or a Remote Config kill switch can flip off. Debug builds report too,
  /// so a development run shows up while testing. Safe to call more than once.
  static Future<void> enableCollection() async {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  @override
  Future<void> recordTrace(String name, Map<String, int> metrics) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    metrics.forEach(trace.setMetric);
    await trace.stop();
  }
}
