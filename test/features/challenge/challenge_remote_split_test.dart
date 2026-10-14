import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_remote_data_source.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';

ChallengeData _profile() => ChallengeData(
      userName: 'Aisha',
      userLocation: 'Dhaka',
      userLatitude: 23.810331,
      userLongitude: 90.412521,
      hasLocation: true,
      challengeStartDate: DateTime(2026, 9),
      isChallengeActive: true,
      currentStreak: 4,
      currentWeek: 2,
      totalQualifyingDays: 9,
      dayLogs: [
        DayLog(
          date: DateTime(2026, 9),
          prayedFajrOnTime: true,
          minutesWorked: 90,
          workDescription: 'private notes',
          workType: WorkType.deepWork,
          reflection: 'private reflection',
          isQualifying: true,
          loggedAt: DateTime(2026, 9, 1, 20),
        ),
      ],
    );

void main() {
  group('public document', () {
    test('holds only the leaderboard fields', () {
      final fields = ChallengeRemoteDataSource.publicFields('u1', _profile());

      expect(fields.keys.toSet(), {
        'uid',
        'userName',
        'userNameLower',
        'location',
        'currentStreak',
        'totalQualifyingDays',
      });
      expect(fields['userNameLower'], 'aisha');
    });

    test('never carries coordinates, dates or logs', () {
      final fields = ChallengeRemoteDataSource.publicFields('u1', _profile());

      for (final key in const [
        'latitude',
        'longitude',
        'startDate',
        'logs',
        'currentWeek',
        'isChallengeActive',
      ]) {
        expect(fields.containsKey(key), isFalse, reason: key);
      }
    });
  });

  group('private document', () {
    test('holds exactly the owner-only fields', () {
      final fields = ChallengeRemoteDataSource.privateFields(_profile());

      expect(fields.keys.toSet(), {
        'latitude',
        'longitude',
        'startDate',
        'isChallengeActive',
        'currentWeek',
        'logs',
      });
      expect(fields['latitude'], 23.810331);
      expect(fields['longitude'], 90.412521);
      expect(fields['logs'] as List, hasLength(1));
    });

    test('does not repeat any public field', () {
      final publicKeys =
          ChallengeRemoteDataSource.publicFields('u1', _profile()).keys.toSet();
      final privateKeys =
          ChallengeRemoteDataSource.privateFields(_profile()).keys.toSet();

      expect(publicKeys.intersection(privateKeys), isEmpty);
    });
  });

  group('parseChallenge', () {
    test('round-trips a profile through the two documents', () {
      final original = _profile();
      final restored = ChallengeRemoteDataSource.parseChallenge({
        ...ChallengeRemoteDataSource.publicFields('u1', original),
        ...ChallengeRemoteDataSource.privateFields(original),
      })!;

      expect(restored.userName, 'Aisha');
      expect(restored.userLocation, 'Dhaka');
      expect(restored.userLatitude, 23.810331);
      expect(restored.userLongitude, 90.412521);
      expect(restored.hasLocation, isTrue);
      expect(restored.challengeStartDate, DateTime(2026, 9));
      expect(restored.isChallengeActive, isTrue);
      expect(restored.currentStreak, 4);
      expect(restored.currentWeek, 2);
      expect(restored.totalQualifyingDays, 9);
      expect(restored.dayLogs, hasLength(1));
      expect(restored.dayLogs.single.workDescription, 'private notes');
    });

    test('restores a legacy profile whose private fields are on the public doc',
        () {
      final restored = ChallengeRemoteDataSource.parseChallenge({
        'uid': 'u1',
        'userName': 'Aisha',
        'location': 'Dhaka',
        'latitude': 23.8,
        'longitude': 90.4,
        'startDate': DateTime(2026, 9).toIso8601String(),
        'currentStreak': 4,
        'totalQualifyingDays': 9,
        'logs': <Map<String, dynamic>>[],
      })!;

      expect(restored.hasLocation, isTrue);
      expect(restored.userLatitude, 23.8);
      expect(restored.isChallengeActive, isTrue);
    });

    test('a public-only profile has a city but no usable location', () {
      final restored = ChallengeRemoteDataSource.parseChallenge(
        ChallengeRemoteDataSource.publicFields('u1', _profile()),
      )!;

      expect(restored.userLocation, 'Dhaka');
      expect(restored.hasLocation, isFalse);
      expect(restored.hasUsableCoordinates, isFalse);
    });

    test('returns null when there is no username', () {
      expect(
          ChallengeRemoteDataSource.parseChallenge({'userName': ' '}), isNull);
    });
  });
}
