import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_repository.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';

/// In-memory fake repository — copied verbatim from
/// challenge_controller_test.dart (the controller depends on the
/// [ChallengeRepository] interface, not SharedPreferences/Firestore
/// directly, which is what makes this fake possible).
class FakeChallengeRepository implements ChallengeRepository {
  ChallengeData stored;
  int saveCount = 0;
  bool usernameTaken = false;
  int reserveCount = 0;
  String? lastReservePrevious;

  FakeChallengeRepository([ChallengeData? initial])
      : stored = initial ?? ChallengeData();

  ChallengeData? remote;

  @override
  ChallengeData load() => stored;

  @override
  Future<ChallengeData?> fetchRemote() async => remote;

  @override
  Future<void> save(ChallengeData data) async {
    stored = data;
    saveCount++;
  }

  @override
  Future<void> saveLocal(ChallengeData data) async {
    stored = data;
    saveCount++;
  }

  @override
  Future<bool> usernameExists(String username, String currentUserName) async =>
      usernameTaken;

  @override
  Future<bool> reserveUsername(String desired, String previous) async {
    reserveCount++;
    lastReservePrevious = previous;
    return !usernameTaken;
  }
}

ChallengeProvider makeProvider({FakeAnalyticsService? analytics}) =>
    ChallengeProvider(FakeChallengeRepository(), analytics: analytics);

void main() {
  test('startChallenge logs challenge_started', () async {
    final analytics = FakeAnalyticsService();
    final provider = makeProvider(analytics: analytics);

    await provider.startChallenge();

    expect(analytics.events.map((e) => e.name), contains('challenge_started'));
  });

  // NOTE: a deterministic "successful logDay logs day_logged" test is not
  // included here. logDay() reads the real DateTime.now() directly (no
  // clock-injection seam exists anywhere in this codebase — see
  // task-2-report.md), and rejects both weekends and any time at/after the
  // 08:00 cutoff. That makes a real-clock success path flaky in CI by
  // construction, not just on weekends. The existing controller test suite
  // has the same gap: its only logDay test (`invalidInput` for an over-long
  // description) never reaches the time checks. Escalated as NEEDS_CONTEXT
  // in the task report rather than committing a test that fails outside a
  // narrow real-world time window.

  test('no analytics events on rejected logDay', () async {
    final analytics = FakeAnalyticsService();
    final provider = makeProvider(analytics: analytics);
    // No startChallenge -> logDay must fail regardless of day/time.

    await provider.logDay(
      prayedFajrOnTime: true,
      prayedAtMasjid: false,
      minutesWorked: 90,
      workDescription: 'Deep work session',
      workType: WorkType.deepWork,
    );

    expect(analytics.events.where((e) => e.name == 'day_logged'), isEmpty);
  });

  test('streakMilestoneFor fires only on exact 7/14/21', () {
    expect(ChallengeProvider.streakMilestoneFor(6), isNull);
    expect(ChallengeProvider.streakMilestoneFor(7), 7);
    expect(ChallengeProvider.streakMilestoneFor(8), isNull);
    expect(ChallengeProvider.streakMilestoneFor(14), 14);
    expect(ChallengeProvider.streakMilestoneFor(21), 21);
    expect(ChallengeProvider.streakMilestoneFor(28), isNull);
  });
}
