import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'challenge_data.dart';

/// Reads/writes challenge state to Cloud Firestore. The only place that knows
/// the Firestore collection layout and document shape.
class ChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChallengeRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'challenges';

  /// Whether [username] is already claimed by someone other than
  /// [currentUserName]. Comparison is trimmed + lowercased.
  Future<bool> usernameExists(String username, String currentUserName) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    try {
      final query = await _firestore
          .collection(_collection)
          .where('userNameLower', isEqualTo: normalized)
          .limit(1)
          .get();

      // Ignore the user's own existing record when re-checking their name.
      return query.docs.any(
        (doc) =>
            (doc.data()['userName'] as String?)?.trim() !=
            currentUserName.trim(),
      );
    } catch (e) {
      debugPrint('Error checking username: $e');
      return false;
    }
  }

  /// Upserts the user's challenge document. No-op if the user has no name yet.
  /// Swallows errors (offline-tolerant) — local prefs remain the source of truth.
  Future<void> saveChallenge(ChallengeData data) async {
    if (data.userName.isEmpty) return;

    try {
      await _firestore.collection(_collection).doc(data.userName).set({
        'userName': data.userName,
        'userNameLower': data.userName.trim().toLowerCase(),
        'location': data.userLocation,
        'startDate': data.challengeStartDate?.toIso8601String(),
        'currentStreak': data.currentStreak,
        'totalQualifyingDays': data.totalQualifyingDays,
        'lastUpdated': FieldValue.serverTimestamp(),
        'logs': data.dayLogs.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Error saving to Firestore: $e');
    }
  }
}
