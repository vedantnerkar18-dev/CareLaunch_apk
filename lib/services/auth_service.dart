import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Everything that talks to Firebase Authentication.
class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  /// True while a new account is being created and its consent record saved,
  /// so the app does not jump to the home screen half way through.
  final ValueNotifier<bool> registering = ValueNotifier(false);

  /// True right after a new account is created, so the app can show the
  /// "About CareLaunch" screen once. The home screen sets it back to false.
  final ValueNotifier<bool> justRegistered = ValueNotifier(false);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(displayName.trim());
  }

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Used to undo a registration whose consent record could not be saved.
  Future<void> deleteCurrentUser() async {
    try {
      await _auth.currentUser?.delete();
    } catch (_) {
      await _auth.signOut();
    }
  }

  static String friendlyMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists. Try signing in.';
        case 'invalid-email':
          return 'That email address does not look right.';
        case 'weak-password':
          return 'Please choose a stronger password (8 or more characters).';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is not correct.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few minutes and try again.';
        case 'network-request-failed':
          return 'No internet connection. Please check it and try again.';
        default:
          return 'Something went wrong (${error.code}). Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}