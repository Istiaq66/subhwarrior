import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:subh_warrior/firebase_options.dart';

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

  /// [init] for a background isolate (alarm callback, background-fetch task).
  ///
  /// Those isolates never run `main()`, so Firebase is not started and the
  /// error hooks are unset: handled errors would be dropped by
  /// [recordNonFatal] and uncaught ones would vanish. Safe to call repeatedly
  /// and never throws.
  static Future<void> initInBackground() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      debugPrint('CrashReporting.initInBackground: Firebase unavailable: $e');
      return;
    }
    await init();
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
