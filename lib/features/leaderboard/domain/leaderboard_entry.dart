/// A single ranked participant on the leaderboard. Rank is positional and
/// assigned by the presentation layer, so it is not stored here.
class LeaderboardEntry {
  final String userName;
  final String location;
  final int qualifyingDays;
  final int currentStreak;

  const LeaderboardEntry({
    required this.userName,
    required this.location,
    required this.qualifyingDays,
    required this.currentStreak,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data) =>
      LeaderboardEntry(
        userName: data['userName'] as String? ?? 'Anonymous',
        location: data['location'] as String? ?? '',
        qualifyingDays: data['totalQualifyingDays'] as int? ?? 0,
        currentStreak: data['currentStreak'] as int? ?? 0,
      );
}
