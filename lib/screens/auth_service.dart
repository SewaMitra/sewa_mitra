import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────
  // STREAMS & GETTERS
  // ──────────────────────────────────────────
  static Stream<User?> get userStream => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  // ──────────────────────────────────────────
  // SIGN IN
  // ──────────────────────────────────────────
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    } catch (_) {
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  // ──────────────────────────────────────────
  // REGISTER  →  also creates Firestore profile
  // ──────────────────────────────────────────
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Save display name in Firebase Auth
      await user.updateDisplayName(fullName.trim());

      // Create user profile document in Firestore
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send email verification
      await user.sendEmailVerification();

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    } catch (_) {
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  // ──────────────────────────────────────────
  // FORGOT PASSWORD
  // ──────────────────────────────────────────
  static Future<AuthResult> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    } catch (_) {
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  // ──────────────────────────────────────────
  // RESEND VERIFICATION EMAIL
  // ──────────────────────────────────────────
  static Future<AuthResult> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthResult.error('No user is signed in.');
      await user.sendEmailVerification();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    } catch (_) {
      return AuthResult.error('Could not resend email. Try again later.');
    }
  }

  // ──────────────────────────────────────────
  // CHECK EMAIL VERIFIED
  // Also updates Firestore when verified for the first time
  // ──────────────────────────────────────────
  static Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    final verified = _auth.currentUser?.emailVerified ?? false;

    if (verified) {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Update Firestore profile so other parts of the app can read it
        await _db.collection('users').doc(uid).update({
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return verified;
  }

  // ──────────────────────────────────────────
  // GET USER PROFILE FROM FIRESTORE
  // ──────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ──────────────────────────────────────────
  // UPDATE USER PROFILE IN FIRESTORE
  // ──────────────────────────────────────────
  static Future<AuthResult> updateProfile({
    String? fullName,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return AuthResult.error('No user is signed in.');

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        if (fullName != null) 'fullName': fullName.trim(),
        ...?extraFields,
      };

      await _db.collection('users').doc(uid).update(updates);

      if (fullName != null) {
        await _auth.currentUser?.updateDisplayName(fullName.trim());
      }

      return AuthResult.success();
    } catch (_) {
      return AuthResult.error('Could not update profile. Try again.');
    }
  }

  // ──────────────────────────────────────────
  // SIGN OUT
  // ──────────────────────────────────────────
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ──────────────────────────────────────────
  // FRIENDLY ERROR MESSAGES
  // ──────────────────────────────────────────
  static String _friendlyError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ──────────────────────────────────────────
// RESULT WRAPPER
// ──────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult._({required this.success, this.errorMessage});

  factory AuthResult.success() => AuthResult._(success: true);
  factory AuthResult.error(String message) =>
      AuthResult._(success: false, errorMessage: message);
}
