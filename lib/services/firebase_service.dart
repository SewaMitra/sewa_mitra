// lib/services/firebase_service.dart
//
// Handles everything Firestore for the profile (no Firebase Storage — free plan):
//   • fetch / save user profile
//   • store profile photo as Base64 string in Firestore
//   • CRUD addresses
//   • save settings

import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/models/user_model.dart';

class FirebaseService {
  // ── Singletons ─────────────────────────────────────────────────────────────
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _db = FirebaseFirestore.instance;

  // ── Collection helpers ──────────────────────────────────────────────────────
  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  CollectionReference _addressCol(String uid) =>
      _db.collection('users').doc(uid).collection('addresses');

  // ══════════════════════════════════════════════════════════════════════════
  //  USER PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch user profile. Returns null if not yet created.
  Future<UserModel?> getUser(String uid) async {
    try {
      final snap = await _userDoc(uid).get();
      if (!snap.exists) return null;
      return UserModel.fromMap(snap.data() as Map<String, dynamic>, uid);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  /// Create or fully replace a user document.
  Future<void> saveUser(UserModel user) async {
    try {
      await _userDoc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Update only specific fields (e.g. name + email after edit profile).
  /// Uses set+merge instead of update() so it works even if doc doesn't exist yet.
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      await _userDoc(uid).set(fields, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PROFILE PHOTO (Base64 — no Firebase Storage needed)
  // ══════════════════════════════════════════════════════════════════════════

  /// Reads the image file, encodes it as Base64, and saves it directly
  /// in the user's Firestore document as 'photoBase64'.
  /// Returns a data URI string: "data:image/jpg;base64,..."
  Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Str = base64Encode(bytes);
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64Str';

      // Store in Firestore — no Storage bucket needed
      await _userDoc(uid).set({'photoBase64': dataUri}, SetOptions(merge: true));

      return dataUri;
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  /// Clears the photo from Firestore.
  Future<void> removeProfilePhoto(String uid, String photoUrl) async {
    try {
      await _userDoc(uid).update({
        'photoBase64': FieldValue.delete(),
        'photoUrl': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to remove photo: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADDRESSES
  // ══════════════════════════════════════════════════════════════════════════

  /// Stream all addresses in real-time (auto-updates the UI).
  Stream<List<UserAddress>> addressStream(String uid) {
    return _addressCol(uid).snapshots().map((snap) => snap.docs
        .map((d) =>
            UserAddress.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  /// Add a new address.
  Future<void> addAddress(String uid, UserAddress address) async {
    try {
      await _addressCol(uid).add(address.toMap());
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  /// Delete an address by its Firestore document ID.
  Future<void> deleteAddress(String uid, String addressId) async {
    try {
      await _addressCol(uid).doc(addressId).delete();
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SETTINGS
  // ══════════════════════════════════════════════════════════════════════════

  /// Save a single settings toggle (e.g. pushNotifications, darkMode).
  Future<void> updateSetting(String uid, String key, bool value) async {
    try {
      await _userDoc(uid).set({key: value}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update setting: $e');
    }
  }
}
