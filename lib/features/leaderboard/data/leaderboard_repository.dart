import '../domain/leaderboard_entry.dart';
import 'leaderboard_remote_data_source.dart';

/// Repository contract for leaderboard data. The screen depends on this, not
/// on Firestore directly (IMPROVEMENT_PLAN B3).
abstract class LeaderboardRepository {
  Stream<List<LeaderboardEntry>> global({int limit});
  Stream<List<LeaderboardEntry>> local(String location);
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource _remote;

  LeaderboardRepositoryImpl({LeaderboardRemoteDataSource? remote})
      : _remote = remote ?? LeaderboardRemoteDataSource();

  @override
  Stream<List<LeaderboardEntry>> global({int limit = 100}) =>
      _remote.globalStream(limit: limit);

  @override
  Stream<List<LeaderboardEntry>> local(String location) =>
      _remote.localStream(location);
}
