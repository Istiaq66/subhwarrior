import 'package:flutter/widgets.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';

/// Screen names reported to Analytics. Wire format — never rename.
abstract final class AnalyticsScreens {
  AnalyticsScreens._();

  static const auth = 'auth';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const progress = 'progress';
  static const leaderboard = 'leaderboard';
  static const logDay = 'log_day';
  static const settings = 'settings';
}

/// Logs a `screen_view` event. Same event and parameters the Firebase SDK's
/// own `logScreenView` sends, routed through [AnalyticsService] so tests can
/// assert on it. Never throws: tracking must not break navigation.
void logScreenView(String screenName) {
  try {
    AnalyticsService.maybeInstance?.logEvent(AnalyticsEvents.screenView, {
      'screen_name': screenName,
      'screen_class': screenName,
    });
  } catch (_) {}
}

/// Logs a screen view once when [child] first appears.
///
/// Used instead of a `NavigatorObserver` because most screens here are swapped
/// in by `_RootRouter` rather than pushed, so the navigator never sees them.
/// Give it a `ValueKey(name)` when the same position can show different
/// screens, or the state (and the log) is reused.
class ScreenView extends StatefulWidget {
  const ScreenView({super.key, required this.name, required this.child});

  final String name;
  final Widget child;

  @override
  State<ScreenView> createState() => _ScreenViewState();
}

class _ScreenViewState extends State<ScreenView> {
  @override
  void initState() {
    super.initState();
    logScreenView(widget.name);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
