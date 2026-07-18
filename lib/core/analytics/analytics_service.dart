/// One logged analytics event (used by [FakeAnalyticsService] assertions).
typedef LoggedEvent = ({String name, Map<String, Object>? parameters});

/// Event-name constants from the growth-plan spec. Names are wire format —
/// never rename without a data-migration decision.
abstract final class AnalyticsEvents {
  AnalyticsEvents._();

  static const challengeStarted = 'challenge_started';
  static const dayLogged = 'day_logged';
  static const streakMilestone = 'streak_milestone';
  static const shareCardSent = 'share_card_sent';
  static const inviteSent = 'invite_sent';
  static const inviteAccepted = 'invite_accepted';
  static const friendAdded = 'friend_added';
  static const notificationOpened = 'notification_opened';
}

/// Analytics abstraction so widgets/controllers never import Firebase
/// directly and tests can assert on events via [FakeAnalyticsService].
abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);

  /// Set once at startup; lets context-free call sites (e.g. the
  /// notification-tap callback) log events. Null in tests unless set.
  static AnalyticsService? maybeInstance;
}

/// In-memory implementation for tests.
class FakeAnalyticsService implements AnalyticsService {
  final List<LoggedEvent> events = [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add((name: name, parameters: parameters));
  }
}
