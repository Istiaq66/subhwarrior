import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'challenge_data.dart';

class _UsernameTakenException implements Exception {}

/// Reads/writes challenge state to Cloud Firestore. The only place that knows
/// the Firestore collection layout and document shape.
///
/// Documents are keyed by the Firebase Auth [uid], never by username
/// (IMPROVEMENT_PLAN A6/D1): keying by username let anyone overwrite a
/// stranger's data by guessing their name, and orphaned the old doc on rename.
class ChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Stable Firebase Auth uid of the signed-in user. Used as the document id.
  final String uid;

  ChallengeRemoteDataSource({required this.uid, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'challenges';
  static const _usernames = 'usernames';

  /// Whether [username] is already claimed by another user. Comparison is
  /// trimmed + lowercased against the `usernames/{lowercased}` reservation
  /// collection. Best-effort pre-check; [reserveUsername] is authoritative.
  Future<bool> usernameExists(String username, String currentUserName) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    try {
      final snap =
          await _firestore.collection(_usernames).doc(normalized).get();
      if (!snap.exists) return false;
      // Not "taken" if the reservation is already ours.
      return snap.data()?['uid'] != uid;
    } catch (e) {
      debugPrint('Error checking username: $e');
      return false;
    }
  }

  /// Atomically reserves [desired] for this uid (IMPROVEMENT_PLAN D4). Releases
  /// the [previous] reservation on rename. Returns `true` on success, `false`
  /// if the name is already held by a different uid. Comparison is
  /// trimmed + lowercased so casing/whitespace can't create duplicates.
  Future<bool> reserveUsername(String desired, String previous) async {
    final normalized = desired.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final ref = _firestore.collection(_usernames).doc(normalized);
    final prevNorm = previous.trim().toLowerCase();

    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(ref);
        if (snap.exists && snap.data()?['uid'] != uid) {
          throw _UsernameTakenException();
        }
        txn.set(ref, {'uid': uid, 'userName': desired.trim()});
        if (prevNorm.isNotEmpty && prevNorm != normalized) {
          txn.delete(_firestore.collection(_usernames).doc(prevNorm));
        }
      });
      return true;
    } on _UsernameTakenException {
      return false;
    } catch (e) {
      debugPrint('Error reserving username: $e');
      return false;
    }
  }

  /// Upserts the user's challenge document, keyed by [uid]. No-op if the user
  /// has no name yet. Swallows errors (offline-tolerant) — local prefs remain
  /// the source of truth.
  Future<void> saveChallenge(ChallengeData data) async {
    if (data.userName.isEmpty) return;

    try {
      await _firestore.collection(_collection).doc(uid).set({
        'uid': uid,
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