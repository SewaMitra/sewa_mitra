import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isDarkMode = false;
  final _firebaseService = FirebaseService();

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Call this once on app start / after login to load the saved preference.
  Future<void> loadFromFirestore() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    try {
      final user = await _firebaseService.getUser(uid);
      if (user != null) {
        _isDarkMode = user.darkMode;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Toggle dark mode and persist to Firestore.
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final uid = AuthService.currentUser?.uid;
    if (uid != null) {
      await _firebaseService.updateSetting(uid, 'darkMode', value);
    }
  }
}
