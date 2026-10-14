import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:subh_warrior/core/crash/crash_reporting.dart';

import '../domain/day_log.dart';
import 'challenge_data.dart';

class _UsernameTakenException implements Exception {}

/// Outcome of a username reservation.
///
/// [failed] is deliberately separate from [taken]: a denied or offline write
/// used to be reported to the user as "that name is taken", which sent them
/// renaming themselves over and over while the real problem was that the
/// profile write never reached Firestore.
enum UsernameReservation { reserved, taken, failed }

/// Reads/writes challenge state to Cloud Firestore. The only place that knows
/// the Firestore collection layout and document shape.
///
/// Documents are keyed by the Firebase Auth [uid], never by username
/// (IMPROVEMENT_PLAN A6/D1): keying by username let anyone overwrite a
/// stranger's data by guessing their name, and orphaned the old doc on rename.
///
/// A user's state is split across two documents with the same id:
///  * `challenges/{uid}` — public, world-readable. Only what the leaderboard
///    shows: name, city name, streak and qualifying days.
///  * `challenge_private/{uid}` — owner-only. Exact coordinates, start date,
///    week and the per-day logs. Never readable by anyone else.
class ChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Stable Firebase Auth uid of the signed-in user. Used as the document id.
  final String uid;

  ChallengeRemoteDataSource({required this.uid, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'challenges';
  static const _privateCollection = 'challenge_private';
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
  /// the [previous] reservation on rename. Comparison is trimmed + lowercased
  /// so casing/whitespace can't create duplicates.
  Future<UsernameReservation> reserveUsername(
      String desired, String previous) async {
    final normalized = desired.trim().toLowerCase();
    if (normalized.isEmpty) return UsernameReservation.failed;
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
      return UsernameReservation.reserved;
    } on _UsernameTakenException {
      return UsernameReservation.taken;
    } catch (e) {
      // Rules denial, offline, transaction abort — anything but the name
      // being held by someone else.
      debugPrint('Error reserving username: $e');
      return UsernameReservation.failed;
    }
  }

  /// Public leaderboard fields. Everything here is readable by any client, so
  /// nothing that locates or profiles the user may be added.
  @visibleForTesting
  static Map<String, dynamic> publicFields(String uid, ChallengeData data) => {
        'uid': uid,
        'userName': data.userName,
        'userNameLower': data.userName.trim().toLowerCase(),
        'location': data.userLocation,
        'currentStreak': data.currentStreak,
        'totalQualifyingDays': data.totalQualifyingDays,
      };

  /// Owner-only fields, kept out of the world-readable leaderboard document.
  @visibleForTesting
  static Map<String, dynamic> privateFields(ChallengeData data) => {
        'latitude': data.userLatitude,
        'longitude': data.userLongitude,
        'startDate': data.challengeStartDate?.toIso8601String(),
        'isChallengeActive': data.isChallengeActive,
        'currentWeek': data.currentWeek,
        'logs': data.dayLogs.map((e) => e.toJson()).toList(),
      };

  /// Upserts the user's public and private documents together, keyed by
  /// [uid]. No-op if the user has no name yet. Swallows errors
  /// (offline-tolerant) — local prefs remain the source of truth.
  ///
  /// Both writes replace the document (no merge), so saving also strips any
  /// private fields older versions left on the public document.
  Future<void> saveChallenge(ChallengeData data) async {
    if (data.userName.isEmpty) return;

    try {
      final batch = _firestore.batch()
        ..set(_firestore.collection(_collection).doc(uid), {
          ...publicFields(uid, data),
          'lastUpdated': FieldValue.serverTimestamp(),
        })
        ..set(
          _firestore.collection(_privateCollection).doc(uid),
          privateFields(data),
        );
      await batch.commit();
    } catch (e, st) {
      debugPrint('Error saving to Firestore: $e');
      CrashReporting.recordNonFatal(e, st, 'Firestore saveChallenge failed');
    }
  }

  /// Permanently deletes everything stored for this user: the public
  /// leaderboard document, the private document and the username reservation.
  ///
  /// Unlike [saveChallenge] this **throws** on failure. Account deletion must
  /// not carry on to delete the sign-in if the data is still on the server.
  /// Deleting a document that does not exist is a no-op, so retrying is safe.
  Future<void> deleteAll(String userName) async {
    final batch = _firestore.batch()
      ..delete(_firestore.collection(_collection).doc(uid))
      ..delete(_firestore.collection(_privateCollection).doc(uid));

    // The rules only allow deleting a reservation that is ours, and evaluate
    // `resource.data` — which does not exist for a missing document — so add
    // the delete only when the reservation is there and held by this uid.
    final normalized = userName.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      final ref = _firestore.collection(_usernames).doc(normalized);
      final snap = await ref.get();
      if (snap.exists && snap.data()?['uid'] == uid) batch.delete(ref);
    }

    await batch.commit();
  }

  Future<ChallengeData?> fetchChallenge() async {
    try {
      final publicSnap =
          await _firestore.collection(_collection).doc(uid).get();
      if (!publicSnap.exists) return null;
      final privateSnap =
          await _firestore.collection(_privateCollection).doc(uid).get();
      // Private wins on overlap. A profile saved before the split still has
      // its private fields on the public document, so it restores from there
      // until its next save moves them.
      return parseChallenge({
        ...?publicSnap.data(),
        ...?privateSnap.data(),
      });
    } catch (e) {
      debugPrint('Error fetching from Firestore: $e');
      return null;
    }
  }

  /// Builds [ChallengeData] from the merged public + private fields, or null
  /// when the profile has no username.
  @visibleForTesting
  static ChallengeData? parseChallenge(Map<String, dynamic> map) {
    final userName = (map['userName'] as String?)?.trim() ?? '';
    if (userName.isEmpty) return null;

    final location = (map['location'] as String?) ?? '';
    final startDateStr = map['startDate'] as String?;
    final logsRaw = (map['logs'] as List?) ?? const [];

    // A remote profile can carry a location *name* with no coordinates
    // (older documents, or a geocode that failed at onboarding). Deriving
    // `hasLocation` from the name alone then restores a profile that claims
    // a location while holding 0,0 — which the prayer-times lookup cannot
    // use, so the home screen shows a permanent "unable to load prayer
    // times". Require the coordinates to be present.
    //
    // Absent is tested, not equality with zero: (0, 0) is a real coordinate
    // in the Gulf of Guinea, per the contract on
    // `ChallengeProvider.hasLocation`.
    final latitude = (map['latitude'] as num?)?.toDouble();
    final longitude = (map['longitude'] as num?)?.toDouble();

    return ChallengeData(
      userName: userName,
      userLocation: location,
      userLatitude: latitude ?? 0.0,
      userLongitude: longitude ?? 0.0,
      hasLocation:
          location.trim().isNotEmpty && latitude != null && longitude != null,
      challengeStartDate:
          startDateStr != null ? DateTime.tryParse(startDateStr) : null,
      isChallengeActive:
          (map['isChallengeActive'] as bool?) ?? (startDateStr != null),
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      currentWeek: (map['currentWeek'] as num?)?.toInt() ?? 1,
      totalQualifyingDays: (map['totalQualifyingDays'] as num?)?.toInt() ?? 0,
      dayLogs: logsRaw
          .map((e) => DayLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
