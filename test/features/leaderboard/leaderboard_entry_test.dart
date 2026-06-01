import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/leaderboard/domain/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry.fromMap', () {
    test('maps a full document', () {
      final entry = LeaderboardEntry.fromMap({
        'userName': 'Warrior',
        'location': 'Dhaka',
        'totalQualifyingDays': 12,
        'currentStreak': 4,
      });
      expect(entry.userName, 'Warrior');
      expect(entry.location, 'Dhaka');
      expect(entry.qualifyingDays, 12);
      expect(entry.currentStreak, 4);
    });

    test('applies defaults for missing/null fields', () {
      final entry = LeaderboardEntry.fromMap({});
      expect(entry.userName, 'Anonymous');
      expect(entry.location, '');
      expect(entry.qualifyingDays, 0);
      expect(entry.currentStreak, 0);
    });
  });
}
