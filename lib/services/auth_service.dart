import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '1090348965383-ufo5ftb59l4lhvp5flr7mn9tpumv5a6g.apps.googleusercontent.com',
  );

  // ──────────────────────────────────────────
  // ROLE CACHE — avoids repeated Firestore calls on every route change
  // ──────────────────────────────────────────
  static String? _cachedRole;
  static String? _cachedUid;
  static String? _activeMode;

  static Future<String> getActiveMode() async {
    if (_activeMode != null) return _activeMode!;
    final profile = await getUserProfile();
    _activeMode = profile?['activeMode'] ?? 'customer';
    return _activeMode!;
  }

  static Future<void> setActiveMode(String mode) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({'activeMode': mode});
      _activeMode = mode;
    }
  }

  static Future<String> getCachedRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'customer';
    // Return cache if same user
    if (_cachedUid == uid && _cachedRole != null) return _cachedRole!;
    // Otherwise fetch and cache
    try {
      final doc = await _db.collection('users').doc(uid).get();
      _cachedRole = doc.data()?['role'] ?? 'customer';
      _cachedUid = uid;
      return _cachedRole!;
    } catch (_) {
      return 'customer';
    }
  }

  static void clearRoleCache() {
    _cachedRole = null;
    _cachedUid = null;
  }

  // ──────────────────────────────────────────
  // STREAMS & GETTERS
  // ──────────────────────────────────────────
  static Stream<User?> get userStream => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  // ──────────────────────────────────────────
  // SIGN IN WITH EMAIL
  // ──────────────────────────────────────────
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        await _db.collection('users').doc(credential.user!.uid).update({
          'isOnline': true,
          'lastLogin': FieldValue.serverTimestamp(),
        }).catchError((_) {}); // Best effort
      }
      
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    } catch (_) {
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  // ──────────────────────────────────────────
  // SIGN IN WITH GOOGLE
  // ──────────────────────────────────────────
  static Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return AuthResult.error('Sign-in cancelled.');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final docRef = _db.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'fullName': user.displayName ?? '',
          'email': user.email ?? '',
          'emailVerified': true,
          'photoUrl': user.photoURL ?? '',
          'provider': 'google',
          'role': 'customer', // ← Always assign role on first Google sign-in
          'isOnline': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          'photoUrl': user.photoURL ?? '',
          'isOnline': true,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} — ${e.message}');
      return AuthResult.error('Firebase: ${e.code} — ${e.message}');
    } catch (e, stack) {
      print('Google Sign-In error: $e');
      print('Stack: $stack');
      return AuthResult.error('Error: $e');
    }
  }

  // ──────────────────────────────────────────
  // REGISTER
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
      await user.updateDisplayName(fullName.trim());

      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'emailVerified': false,
        'photoUrl': '',
        'provider': 'email',
        'role': 'customer', // ← Always assign role on registration
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

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
  // ──────────────────────────────────────────
  static Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    final verified = _auth.currentUser?.emailVerified ?? false;

    if (verified) {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).update({
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return verified;
  }

  // ──────────────────────────────────────────
  // GET USER PROFILE
  // ──────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ──────────────────────────────────────────
  // UPDATE PROFILE
  // ──────────────────────────────────────────
  static Future<AuthResult> updateProfile({
    String? fullName,
    String? photoUrl,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return AuthResult.error('No user is signed in.');

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        if (fullName != null) 'fullName': fullName.trim(),
        if (photoUrl != null) 'photoUrl': photoUrl,
        ...?extraFields,
      };

      await _db.collection('users').doc(uid).update(updates);
      if (fullName != null) {
        await _auth.currentUser?.updateDisplayName(fullName.trim());
      }
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      return AuthResult.success();
    } catch (_) {
      return AuthResult.error('Could not update profile. Try again.');
    }
  }

  // ──────────────────────────────────────────
  // UPLOAD PROFILE IMAGE
  // ──────────────────────────────────────────
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final ref = _storage.ref().child('user_profiles').child('$uid.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────
  // SIGN OUT
  // ──────────────────────────────────────────
  static Future<void> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Update user status in "backend" (Firestore) before signing out
        await _db.collection('users').doc(uid).update({
          'isOnline': false,
          'lastLogout': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 2)).catchError((e) {
          print('Error updating logout status: $e');
        });
      }
    } catch (e) {
      print('Logout status update failed: $e');
    } finally {
      // Always sign out locally and clear cache
      clearRoleCache();
      await _googleSignIn.signOut();
      await _auth.signOut();
    }
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
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
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
