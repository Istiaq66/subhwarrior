import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics wiring. Call [init] once Firebase is initialized; until then
/// (and in tests) every method is a safe no-op.
class CrashReporting {
  CrashReporting._();

  static bool _ready = false;

  /// Routes uncaught Flutter and platform errors to Crashlytics. Collection is
  /// off in debug builds so development noise never reaches the dashboard.
  static Future<void> init() async {
    if (_ready) return;
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      final previousFlutterHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        crashlytics.recordFlutterFatalError(details);
        previousFlutterHandler?.call(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
      _ready = true;
    } catch (e) {
      debugPrint('CrashReporting.init skipped: $e');
    }
  }

  /// Ties reports to the Firebase uid (an opaque id, no personal data).
  static Future<void> setUser(String uid) async {
    if (!_ready || uid.isEmpty) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(uid);
    } catch (_) {}
  }

  /// Records a handled error that would otherwise only be `debugPrint`ed.
  /// Fire-and-forget and never throws, so it is safe inside a `catch`.
  static void recordNonFatal(Object error, StackTrace? stack, String reason) {
    if (!_ready) return;
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
    } catch (_) {}
  }
}
