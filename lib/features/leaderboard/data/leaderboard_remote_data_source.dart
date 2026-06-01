import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/leaderboard_entry.dart';

/// Streams leaderboard data from Cloud Firestore. The only place that knows
/// the collection layout and ranking queries.
class LeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeaderboardRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'challenges';

  /// Global ranking: server-side ordered by qualifying days, capped at [limit].
  Stream<List<LeaderboardEntry>> globalStream({int limit = 100}) {
    return _firestore
        .collection(_collection)
        .orderBy('totalQualifyingDays', descending: true)
        .limit(limit)
        .snapshots()
        .map(_toEntries);
  }

  /// Local ranking: filtered by [location], sorted client-side to avoid a
  /// composite index (where + orderBy on different fields).
  Stream<List<LeaderboardEntry>> localStream(String location) {
    return _firestore
        .collection(_collection)
        .where('location', isEqualTo: location)
        .snapshots()
        .map((snapshot) {
      final entries = _toEntries(snapshot);
      entries.sort((a, b) => b.qualifyingDays.compareTo(a.qualifyingDays));
      return entries;
    });
  }

  List<LeaderboardEntry> _toEntries(QuerySnapshot snapshot) => snapshot.docs
      .map(
          (doc) => LeaderboardEntry.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}
