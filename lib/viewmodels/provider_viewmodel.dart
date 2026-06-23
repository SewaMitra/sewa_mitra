import 'package:flutter/material.dart';
import '../services/provider_service.dart';
import '../models/backend_models.dart';

class ProviderViewModel extends ChangeNotifier {
  final ProviderService _providerService = ProviderService();

  ProviderModel? _provider;
  ProviderApplicationModel? _application;
  List<ProviderModel> _providers = [];
  List<EarningModel> _earnings = [];
  Map<String, double> _earningSummary = {};

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  // Getters
  ProviderModel? get provider => _provider;
  ProviderApplicationModel? get application => _application;
  List<ProviderModel> get providers => _providers;
  List<EarningModel> get earnings => _earnings;
  Map<String, double> get earningSummary => _earningSummary;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  bool get isProvider => _provider != null;
  bool get hasPendingApplication => _application?.status == 'pending';

  // Load provider data
  Future<void> loadProviderData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadMyProvider(),
        _loadApplication(),
        _loadEarnings(),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> _loadMyProvider() async {
    _provider = await _providerService.getMyProviderProfile();
    notifyListeners();
  }

  Future<void> _loadApplication() async {
    _application = await _providerService.getApplicationStatus();
    notifyListeners();
  }

  Future<void> _loadEarnings() async {
    if (_provider != null) {
      _providerService.getProviderEarnings(_provider!.id).listen((earnings) {
        _earnings = earnings;
        notifyListeners();
      });

      _earningSummary = await _providerService.getEarningSummary(_provider!.id);
      notifyListeners();
    }
  }

  // Apply as provider
  Future<bool> applyAsProvider({
    required String fullName,
    required String businessName,
    required String description,
    required List<String> services,
    required String category,
    required String phone,
    required bool documentsUploaded,
  }) async {
    _setProcessing(true);
    try {
      final result = await _providerService.applyAsProvider(
        fullName: fullName,
        businessName: businessName,
        description: description,
        services: services,
        category: category,
        phone: phone,
        documentsUploaded: documentsUploaded,
      );

      if (result['success'] == true) {
        await _loadApplication();
        _setProcessing(false);
        return true;
      }

      _error = result['error'] ?? 'Application failed';
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Update provider profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _setProcessing(true);
    try {
      final success = await _providerService.updateProviderProfile(updates);
      if (success) {
        await _loadMyProvider();
        _setProcessing(false);
        return true;
      }
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Get all providers
  void loadAllProviders({bool activeOnly = true}) {
    _providerService.getAllProviders(activeOnly: activeOnly).listen((providers) {
      _providers = providers;
      notifyListeners();
    });
  }

  // Get providers by category
  void loadProvidersByCategory(String category) {
    _providerService.getProvidersByCategory(category).listen((providers) {
      _providers = providers;
      notifyListeners();
    });
  }

  // Search providers
  void searchProviders(String query) {
    _providerService.searchProviders(query).listen((providers) {
      _providers = providers;
      notifyListeners();
    });
  }

  // Get provider profile by ID
  Future<ProviderModel?> getProviderById(String providerId) async {
    return await _providerService.getProviderProfile(providerId);
  }

  // Withdraw earnings
  Future<bool> withdrawEarnings(double amount) async {
    if (_provider == null) return false;

    _setProcessing(true);
    try {
      final success = await _providerService.withdrawEarnings(_provider!.id, amount);
      if (success) {
        await _loadEarnings();
        _setProcessing(false);
        return true;
      }
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Admin actions
  Future<bool> approveApplication(String applicationId) async {
    _setProcessing(true);
    try {
      final success = await _providerService.approveApplication(applicationId);
      if (success) {
        await loadProviderData();
        _setProcessing(false);
        return true;
      }
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  Future<bool> rejectApplication(String applicationId, String reason) async {
    _setProcessing(true);
    try {
      final success = await _providerService.rejectApplication(applicationId, reason);
      if (success) {
        await loadProviderData();
        _setProcessing(false);
        return true;
      }
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  Future<bool> suspendProvider(String providerId, String reason) async {
    _setProcessing(true);
    try {
      final success = await _providerService.suspendProvider(providerId, reason);
      if (success) {
        loadAllProviders();
        _setProcessing(false);
        return true;
      }
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  Future<bool> restoreProvider(String providerId) async {
    _setProcessing(true);
    try {
      final success = await _providerService.restoreProvider(providerId);
      if (success) {
        loadAllProviders();
        _setProcessing(false);
        return true;
      }
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Load all applications (admin)
  void loadAllApplications({String? status}) {
    _providerService.getAllApplications(status: status).listen((applications) {
      // Convert to list and store
      notifyListeners();
    });
  }

  // Refresh
  Future<void> refresh() async {
    await loadProviderData();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }
}