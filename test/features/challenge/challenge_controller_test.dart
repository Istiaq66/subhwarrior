import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/utils/date_time_utils.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_repository.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';

/// In-memory fake repository — possible only because the controller depends on
/// the [ChallengeRepository] interface, not SharedPreferences/Firestore
/// directly (the point of the Phase B split).
class FakeChallengeRepository implements ChallengeRepository {
  ChallengeData stored;
  int saveCount = 0;
  bool usernameTaken = false;

  FakeChallengeRepository([ChallengeData? initial])
      : stored = initial ?? ChallengeData();

  @override
  ChallengeData load() => stored;

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
}

void main() {
  group('startChallenge', () {
    test('begins today, not next Sunday', () async {
      final repo = FakeChallengeRepository();
      final controller = ChallengeProvider(repo);

      await controller.startChallenge();

      final today = AppDateUtils.dateOnly(DateTime.now());
      expect(controller.challengeStartDate, today);
      expect(controller.isChallengeActive, isTrue);
      expect(controller.currentWeek, 1);
      expect(controller.dayLogs, isEmpty);
    });

    test('persists through the repository', () async {
      final repo = FakeChallengeRepository();
      final controller = ChallengeProvider(repo);

      await controller.startChallenge();

      expect(repo.saveCount, greaterThan(0));
      expect(repo.stored.isChallengeActive, isTrue);
    });
  });

  group('updateUserSettings', () {
    test('throws when the new username is taken', () async {
      final repo = FakeChallengeRepository()..usernameTaken = true;
      final controller = ChallengeProvider(repo);

      expect(
        () => controller.updateUserSettings(
          name: 'taken',
          location: 'Dhaka',
          latitude: 23.8,
          longitude: 90.4,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('sets hasLocation true only for a non-empty location', () async {
      final repo = FakeChallengeRepository();
      final controller = ChallengeProvider(repo);

      await controller.updateUserSettings(
        name: 'warrior',
        location: 'Dhaka',
        latitude: 23.8,
        longitude: 90.4,
      );
      expect(controller.hasLocation, isTrue);

      await controller.updateUserSettings(
        name: 'warrior',
        location: '   ',
        latitude: 0,
        longitude: 0,
      );
      expect(controller.hasLocation, isFalse);
    });
  });

  group('loads initial state from the repository', () {
    test('reflects stored data on construction', () {
      final repo = FakeChallengeRepository(
        ChallengeData(currentStreak: 5, totalQualifyingDays: 12),
      );
      final controller = ChallengeProvider(repo);

      expect(controller.currentStreak, 5);
      expect(controller.totalQualifyingDays, 12);
      // 12 / 16 qualifying-days goal.
      expect(controller.overallProgress, closeTo(0.75, 1e-9));
    });
  });
}