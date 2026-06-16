import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when Google sign-in cannot proceed because the OAuth server client
/// ID has not been configured yet (see [AuthService.googleServerClientId]).
class GoogleSignInNotConfigured implements Exception {
  @override
  String toString() =>
      'Google sign-in is not configured. Enable the Google provider in the '
      'Firebase console, add the app SHA-256, re-download google-services.json, '
      'and set AuthService.googleServerClientId to the Web client OAuth ID.';
}

/// Owns all Firebase Auth + Google Sign-In I/O. The only place that touches
/// `FirebaseAuth` / `GoogleSignIn`. Keyed by a stable [uid] that survives the
/// anonymous → Google upgrade (linking preserves the uid), so every Firestore
/// document can safely use it as the doc id (IMPROVEMENT_PLAN D1 / A6).
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// OAuth 2.0 **Web** client ID from the Firebase console (Authentication →
  /// Sign-in method → Google → Web SDK configuration). Required by
  /// google_sign_in 7.x on Android to obtain a Firebase-usable `idToken`.
  /// Empty until the console step is done — Google sign-in is disabled until then.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Ensures there is a signed-in user, creating an anonymous one if needed.
  /// Returns the stable uid. Call once at startup before any Firestore write.
  Future<String> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    return _auth.currentUser!.uid;
  }

  /// Upgrades the current (anonymous) account to a Google account, preserving
  /// the uid via credential linking. If that Google account is already linked
  /// to a different Firebase user, falls back to signing into that account.
  ///
  /// Throws [GoogleSignInNotConfigured] if [googleServerClientId] is unset.
  Future<UserCredential> signInWithGoogle() async {
    if (googleServerClientId.isEmpty) {
      throw GoogleSignInNotConfigured();
    }

    final signIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await signIn.initialize(serverClientId: googleServerClientId);
      _googleInitialized = true;
    }

    final account = await signIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google sign-in returned no ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final user = _auth.currentUser;

    // Prefer linking so the anonymous uid (and its Firestore doc) survives.
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        // Google account already attached to another user — sign into it.
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          return await _auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google signOut: $e');
    }
    await _auth.signOut();
  }
}