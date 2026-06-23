import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import '../services/payment_service.dart';
import '../models/backend_models.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final PaymentService _paymentService = PaymentService();

  Wallet? _wallet;
  List<TransactionModel> _transactions = [];
  List<PaymentModel> _payments = [];
  List<SavedCardModel> _savedCards = [];

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  // Getters
  Wallet? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  List<PaymentModel> get payments => _payments;
  List<SavedCardModel> get savedCards => _savedCards;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  double get balance => _wallet?.balance ?? 0.0;

  // Load wallet data
  Future<void> loadWalletData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadWallet(),
        _loadTransactions(),
        _loadPayments(),
        _loadSavedCards(),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> _loadWallet() async {
    _wallet = await _walletService.getWallet();
    notifyListeners();
  }

  Future<void> _loadTransactions() async {
    _walletService.getTransactionHistory().listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    });
  }

  Future<void> _loadPayments() async {
    _paymentService.getPaymentHistory().listen((payments) {
      _payments = payments;
      notifyListeners();
    });
  }

  Future<void> _loadSavedCards() async {
    _paymentService.getSavedCards().listen((cards) {
      _savedCards = cards;
      notifyListeners();
    });
  }

  // Add money to wallet
  Future<bool> addMoney({
    required double amount,
    required String method,
    String? cardId,
    String? description,
  }) async {
    _setProcessing(true);
    try {
      // Process payment
      final result = await _paymentService.processPayment(
        bookingId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        method: method,
        cardId: cardId,
        useWallet: false,
      );

      if (result['success'] == true) {
        // Add money to wallet
        final added = await _walletService.addMoney(
          amount: amount,
          description: description ?? 'Added money via $method',
          paymentId: result['paymentId'],
        );

        if (added) {
          await _loadWallet();
          _setProcessing(false);
          return true;
        }
      }

      _error = result['error'] ?? 'Payment failed';
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Send money to another user
  Future<bool> sendMoney({
    required String receiverId,
    required double amount,
    String? description,
  }) async {
    _setProcessing(true);
    try {
      final success = await _walletService.sendMoney(
        receiverId: receiverId,
        amount: amount,
        description: description,
      );

      if (success) {
        await _loadWallet();
        _setProcessing(false);
        return true;
      }

      _error = 'Insufficient balance or invalid receiver';
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Save card
  Future<bool> saveCard({
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
  }) async {
    _setProcessing(true);
    try {
      final success = await _paymentService.saveCard(
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        cvv: cvv,
      );

      if (success) {
        await _loadSavedCards();
        _setProcessing(false);
        return true;
      }

      _error = 'Failed to save card';
      _setProcessing(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setProcessing(false);
      return false;
    }
  }

  // Set default card
  Future<bool> setDefaultCard(String cardId) async {
    _setProcessing(true);
    try {
      final success = await _paymentService.setDefaultCard(cardId);
      if (success) {
        await _loadSavedCards();
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

  // Delete card
  Future<bool> deleteCard(String cardId) async {
    _setProcessing(true);
    try {
      final success = await _paymentService.deleteCard(cardId);
      if (success) {
        await _loadSavedCards();
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

  // Get transaction by ID
  Future<TransactionModel?> getTransaction(String transactionId) async {
    return await _walletService.getTransactionById(transactionId);
  }

  // Get payment summary
  Future<Map<String, double>> getPaymentSummary() async {
    return await _paymentService.getPaymentSummary();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadWalletData();
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