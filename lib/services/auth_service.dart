// lib/services/auth_service.dart
//
// Three login methods:
//   1. Phone OTP  (most common in Nepal)
//   2. Email + Password
//   3. Google Sign-In
//
// After any successful sign-in, call createUserIfNew() to ensure
// the Firestore user document exists.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // ── Singletons ─────────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  // ── Convenience ────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ══════════════════════════════════════════════════════════════════════════
  //  1. PHONE OTP
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Usage in UI:
  //   Step 1 — call sendOtp('+977XXXXXXXXXX', onCodeSent: (vid) { ... })
  //   Step 2 — call verifyOtp(verificationId, otpCode)

  Future<void> sendOtp({
    required String phoneNumber, // must include country code: +977...
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential)? onAutoVerified, // Android only
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        // Android only: auto-fill OTP
        await _auth.signInWithCredential(cred);
        onAutoVerified?.call(cred);
      },
      verificationFailed: (e) {
        onError(e.message ?? 'OTP verification failed');
      },
      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(cred);
      await createUserIfNew(result.user!);
      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Invalid OTP');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  2. EMAIL + PASSWORD
  // ══════════════════════════════════════════════════════════════════════════

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName(name);
      await createUserIfNew(result.user!, name: name);
      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await createUserIfNew(result.user!);
      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  3. GOOGLE SIGN-IN
  // ══════════════════════════════════════════════════════════════════════════

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      await createUserIfNew(result.user!,
          name: googleUser.displayName ?? '',
          photoUrl: googleUser.photoUrl);
      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SIGN OUT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE ACCOUNT
  // ══════════════════════════════════════════════════════════════════════════

  /// Deletes Firestore doc + Firebase Auth account.
  /// Note: Re-authentication may be required for sensitive operations.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Delete Firestore data first
      await _db.collection('users').doc(user.uid).delete();
      // Then delete the Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'Please log out and log back in before deleting your account.');
      }
      throw Exception(e.message);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Creates a Firestore user document only on first sign-in.
  Future<void> createUserIfNew(User user,
      {String? name, String? photoUrl}) async {
    final doc = _db.collection('users').doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'name': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'photoUrl': photoUrl ?? user.photoURL,
        'pushNotifications': true,
        'emailUpdates': false,
        'darkMode': false,
        'locationAccess': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
