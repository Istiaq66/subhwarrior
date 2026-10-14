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

/// Thrown by [AuthService.reauthenticate] when the account signs in with a
/// password and none was supplied, so the caller can ask for one.
class PasswordRequiredException implements Exception {
  @override
  String toString() => 'This account needs its password to confirm.';
}

/// Owns all Firebase Auth + Google Sign-In I/O. The only place that touches
/// `FirebaseAuth` / `GoogleSignIn`. Keyed by a stable [uid] that survives the
/// anonymous → Google upgrade (linking preserves the uid), so every Firestore
/// document can safely use it as the doc id (IMPROVEMENT_PLAN D1 / A6).
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// OAuth 2.0 **Web** client ID (google_sign_in 7.x needs it on Android to
  /// obtain a Firebase-usable `idToken`). This is the `client_type: 3` entry in
  /// the committed `android/app/google-services.json` — it is public config,
  /// not a secret, so it is safe to hardcode as the default. Overridable per
  /// build via `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '798483347271-55srhmpqcn2vc0n366b2oh42bko433fu.apps.googleusercontent.com',
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
    try {
      final credential = await _googleCredential();
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
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in FirebaseAuthException: '
          '${e.code} — ${e.message}');
      rethrow;
    } on GoogleSignInException catch (e) {
      debugPrint('Google sign-in cancelled/failed: '
          '${e.code} — ${e.description}');
      rethrow;
    } catch (e, st) {
      debugPrint('Google sign-in error: $e\n$st');
      rethrow;
    }
  }

  /// Shows the Google account chooser and returns a Firebase credential for
  /// the chosen account. Throws [GoogleSignInNotConfigured] if the OAuth
  /// client ID is unset.
  Future<AuthCredential> _googleCredential() async {
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
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  bool _hasProvider(String providerId) =>
      _auth.currentUser?.providerData.any((p) => p.providerId == providerId) ??
      false;

  /// Whether the signed-in account uses Google. Reauthenticating it needs no
  /// typing, only the Google account chooser.
  bool get usesGoogle => _hasProvider(GoogleAuthProvider.PROVIDER_ID);

  /// Whether the signed-in account has to confirm with its password and has no
  /// Google sign-in to use instead.
  bool get needsPasswordToConfirm =>
      !usesGoogle && _hasProvider(EmailAuthProvider.PROVIDER_ID);

  /// Proves the person holding the phone owns the signed-in account, which
  /// Firebase requires before deleting it. Anonymous accounts have nothing to
  /// prove and return immediately.
  ///
  /// Throws [PasswordRequiredException] if a password account is given no
  /// [password]. A cancelled Google chooser or a wrong password throws, so the
  /// caller stops before anything is deleted.
  Future<void> reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    if (usesGoogle) {
      await user.reauthenticateWithCredential(await _googleCredential());
      return;
    }
    if (_hasProvider(EmailAuthProvider.PROVIDER_ID)) {
      final email = user.email;
      if (password == null || password.isEmpty || email == null) {
        throw PasswordRequiredException();
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    }
  }

  /// Permanently deletes the signed-in Firebase account, then starts a fresh
  /// anonymous session for the same reason [signOut] does: the app always
  /// needs a uid. Call [reauthenticate] first, and delete the user's data
  /// first — once the account is gone the Firestore rules no longer let that
  /// data be removed.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google signOut after delete: $e');
    }
    await _auth.signInAnonymously();
  }

  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final credential = EmailAuthProvider.credential(
      email: normalizedEmail,
      password: password,
    );
    final user = _auth.currentUser;
    try {
      if (user != null && user.isAnonymous) {
        return await user.linkWithCredential(credential);
      }
      return await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Email register FirebaseAuthException: ${e.code} — ${e.message}');
      final current = _auth.currentUser;
      final isOwnEmail =
          current?.email?.toLowerCase() == normalizedEmail.toLowerCase();
      if (isOwnEmail &&
          (e.code == 'email-already-in-use' ||
              e.code == 'credential-already-in-use' ||
              e.code == 'provider-already-linked')) {
        return null;
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Email sign-in FirebaseAuthException: ${e.code} — ${e.message}');
      rethrow;
    }
  }

  /// Sends a password-reset email. Throws [FirebaseAuthException] on bad input.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Signs out, then immediately re-establishes a fresh anonymous session so the
  /// app always has a stable uid. This keeps the unauthenticated UI working and,
  /// crucially, lets a subsequent register *link* (uid stable) instead of
  /// creating a new user mid-flow (which would switch uid and strand the write).
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google signOut: $e');
    }
    await _auth.signOut();
    await _auth.signInAnonymously();
  }
}
