import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';

/// Production implementation backed by Firebase Analytics.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _analytics.logEvent(name: name, parameters: parameters);
}
