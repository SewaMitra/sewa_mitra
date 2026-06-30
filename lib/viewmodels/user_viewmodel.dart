import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserViewModel extends ChangeNotifier {
  String _activeMode = 'customer';
  bool _isProvider = false;
  bool _isLoading = true;

  String get activeMode => _activeMode;
  bool get isProvider => _isProvider;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final profile = await AuthService.getUserProfile();
    if (profile != null) {
      _activeMode = profile['activeMode'] ?? 'customer';
      _isProvider = profile['isProvider'] ?? false;
      // Also check role as fallback
      if (profile['role'] == 'provider') _isProvider = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> switchMode() async {
    final newMode = _activeMode == 'customer' ? 'provider' : 'customer';
    _activeMode = newMode;
    notifyListeners();
    await AuthService.setActiveMode(newMode);
  }

  void setProviderStatus(bool status) {
    _isProvider = status;
    notifyListeners();
  }
}
