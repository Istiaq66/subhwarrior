import 'package:shared_preferences/shared_preferences.dart';

import 'challenge_data.dart';
import 'challenge_local_data_source.dart';
import 'challenge_remote_data_source.dart';

/// Repository contract for challenge persistence. The controller depends on
/// this interface, not on SharedPreferences/Firestore directly (IMPROVEMENT_PLAN B3).
abstract class ChallengeRepository {
  /// Loads the persisted challenge state from local storage.
  ChallengeData load();

  /// Persists state locally and (best-effort) syncs to the remote.
  Future<void> save(ChallengeData data);

  /// Persists state locally only (no remote write) — for settings that don't
  /// belong in the leaderboard document (e.g. notification prefs).
  Future<void> saveLocal(ChallengeData data);

  /// Whether [username] is taken by someone other than [currentUserName].
  Future<bool> usernameExists(String username, String currentUserName);
}

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeLocalDataSource _local;
  final ChallengeRemoteDataSource _remote;

  ChallengeRepositoryImpl(this._local, this._remote);

  /// Convenience constructor wiring the default local + remote data sources.
  factory ChallengeRepositoryImpl.fromPrefs(SharedPreferences prefs) =>
      ChallengeRepositoryImpl(
        ChallengeLocalDataSource(prefs),
        ChallengeRemoteDataSource(),
      );

  @override
  ChallengeData load() => _local.load();

  @override
  Future<void> save(ChallengeData data) async {
    await _local.save(data);
    await _remote.saveChallenge(data);
  }

  @override
  Future<void> saveLocal(ChallengeData data) => _local.save(data);

  @override
  Future<bool> usernameExists(String username, String currentUserName) =>
      _remote.usernameExists(username, currentUserName);
}
