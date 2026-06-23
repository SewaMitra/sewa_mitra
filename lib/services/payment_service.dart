import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sewa_mitra/services/provider_service.dart';
import '../models/backend_models.dart';
import 'wallet_service.dart';




class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WalletService _walletService = WalletService();
  final ProviderService _providerService = ProviderService();

  // Process payment for booking
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required double amount,
    required String method,
    String? cardId,
    String? providerId,
    bool useWallet = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      // Get booking details
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        return {'success': false, 'error': 'Booking not found'};
      }

      final bookingData = bookingDoc.data()!;
      final providerIdFromBooking = bookingData['providerId'] ?? providerId;

      // Start a batch operation
      final batch = _firestore.batch();

      // Create payment record
      final paymentRef = _firestore.collection('payments').doc();
      final payment = PaymentModel(
        id: paymentRef.id,
        userId: user.uid,
        bookingId: bookingId,
        amount: amount,
        currency: 'USD',
        method: method,
        status: 'pending',
        cardId: cardId,
        providerId: providerIdFromBooking,
        createdAt: DateTime.now(),
      );

      batch.set(paymentRef, payment.toFirestore());

      // Process based on payment method
      String paymentStatus = 'completed';

      switch (method) {
        case 'Wallet Balance':
        // Deduct from wallet
          final deducted = await _walletService.deductBalance(
            amount: amount,
            description: 'Payment for booking $bookingId',
            bookingId: bookingId,
          );
          if (!deducted) {
            return {'success': false, 'error': 'Insufficient wallet balance'};
          }
          break;

        case 'Credit Card':
        case 'Debit Card':
        // Process card payment (Stripe/PayPal)
          final cardSuccess = await _processCardPayment(
            amount: amount,
            cardId: cardId,
            bookingId: bookingId,
          );
          if (!cardSuccess) {
            paymentStatus = 'failed';
          }
          break;

        case 'eSewa':
        case 'Khalti':
        // Process mobile wallet payment
          final walletSuccess = await _processMobilePayment(
            amount: amount,
            method: method,
            bookingId: bookingId,
          );
          if (!walletSuccess) {
            paymentStatus = 'failed';
          }
          break;

        case 'Cash on Service':
        // Cash payment - mark as pending
          paymentStatus = 'pending';
          break;

        default:
          return {'success': false, 'error': 'Invalid payment method'};
      }

      // Update payment status
      if (paymentStatus == 'completed') {
        batch.update(paymentRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Update booking status
        batch.update(
          _firestore.collection('bookings').doc(bookingId),
          {
            'status': 'confirmed',
            'paymentId': paymentRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Add to provider's earnings (80% to provider, 20% platform fee)
        if (providerIdFromBooking != null) {
          await _providerService.addEarning(
            providerId: providerIdFromBooking,
            bookingId: bookingId,
            amount: amount,
            paymentId: paymentRef.id,
          );
        }

        // Create transaction record
        final transactionRef = _firestore.collection('transactions').doc();
        final transaction = TransactionModel(
          id: transactionRef.id,
          userId: user.uid,
          type: 'payment',
          amount: -amount,
          status: 'completed',
          description: 'Payment for booking $bookingId',
          senderId: user.uid,
          bookingId: bookingId,
          paymentId: paymentRef.id,
          createdAt: DateTime.now(),
        );
        batch.set(transactionRef, transaction.toFirestore());

        await batch.commit();
        return {'success': true, 'paymentId': paymentRef.id};
      } else if (paymentStatus == 'pending') {
        batch.update(paymentRef, {'status': 'pending'});
        await batch.commit();
        return {'success': true, 'paymentId': paymentRef.id, 'status': 'pending'};
      } else {
        batch.update(paymentRef, {'status': 'failed'});
        await batch.commit();
        return {'success': false, 'error': 'Payment failed'};
      }
    } catch (e) {
      print('Payment error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Process card payment
  Future<bool> _processCardPayment({
    required double amount,
    String? cardId,
    String? bookingId,
  }) async {
    try {
      // Integration with Stripe/PayPal
      // For now, simulate success
      // In production, you would call Stripe API
      return true;
    } catch (e) {
      print('Card payment error: $e');
      return false;
    }
  }

  // Process mobile wallet payment
  Future<bool> _processMobilePayment({
    required double amount,
    required String method,
    String? bookingId,
  }) async {
    try {
      // Integration with eSewa/Khalti API
      // For now, simulate success
      return true;
    } catch (e) {
      print('Mobile payment error: $e');
      return false;
    }
  }

  // Save card for future payments
  Future<bool> saveCard({
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
    String? stripePaymentMethodId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if this is the first card
      final cardsSnapshot = await _firestore
          .collection('saved_cards')
          .where('userId', isEqualTo: user.uid)
          .get();

      final isFirstCard = cardsSnapshot.docs.isEmpty;

      final cardRef = _firestore.collection('saved_cards').doc();
      final card = SavedCardModel(
        id: cardRef.id,
        userId: user.uid,
        cardNumber: '****${cardNumber.substring(cardNumber.length - 4)}',
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        cardType: _getCardType(cardNumber),
        isDefault: isFirstCard,
        stripePaymentMethodId: stripePaymentMethodId,
      );

      await cardRef.set({
        'userId': card.userId,
        'cardNumber': card.cardNumber,
        'cardHolderName': card.cardHolderName,
        'expiryDate': card.expiryDate,
        'cardType': card.cardType,
        'isDefault': card.isDefault,
        'stripePaymentMethodId': card.stripePaymentMethodId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error saving card: $e');
      return false;
    }
  }

  // Get saved cards
  Stream<List<SavedCardModel>> getSavedCards() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('saved_cards')
        .where('userId', isEqualTo: user.uid)
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SavedCardModel.fromFirestore(doc))
        .toList());
  }

  // Set default card
  Future<bool> setDefaultCard(String cardId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final batch = _firestore.batch();

      // Remove default from all cards
      final cardsSnapshot = await _firestore
          .collection('saved_cards')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in cardsSnapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set new default
      batch.update(_firestore.collection('saved_cards').doc(cardId), {
        'isDefault': true,
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error setting default card: $e');
      return false;
    }
  }

  // Delete saved card
  Future<bool> deleteCard(String cardId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('saved_cards').doc(cardId).delete();
      return true;
    } catch (e) {
      print('Error deleting card: $e');
      return false;
    }
  }

  // Get card type from number
  String _getCardType(String number) {
    if (number.startsWith('4')) return 'visa';
    if (number.startsWith('5')) return 'mastercard';
    if (number.startsWith('3')) return 'amex';
    return 'unknown';
  }

  // Get payment history
  Stream<List<PaymentModel>> getPaymentHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList());
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return PaymentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting payment: $e');
      return null;
    }
  }

  // Refund payment
  Future<bool> refundPayment(String paymentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final paymentDoc = await _firestore
          .collection('payments')
          .doc(paymentId)
          .get();

      if (!paymentDoc.exists) return false;

      final paymentData = paymentDoc.data()!;
      final amount = (paymentData['amount'] ?? 0).toDouble();
      final method = paymentData['method'] ?? '';

      final batch = _firestore.batch();

      // Update payment status
      batch.update(
        _firestore.collection('payments').doc(paymentId),
        {
          'status': 'refunded',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Refund based on payment method
      if (method == 'Wallet Balance') {
        await _walletService.addMoney(
          amount: amount,
          description: 'Refund for payment $paymentId',
          paymentId: paymentId,
        );
      } else {
        // Process refund through payment gateway
        // In production, call Stripe/PayPal refund API
      }

      // Create refund transaction
      final transactionRef = _firestore.collection('transactions').doc();
      final transaction = TransactionModel(
        id: transactionRef.id,
        userId: user.uid,
        type: 'refund',
        amount: amount,
        status: 'completed',
        description: 'Refund for payment $paymentId',
        senderId: user.uid,
        paymentId: paymentId,
        createdAt: DateTime.now(),
      );
      batch.set(transactionRef, transaction.toFirestore());

      await batch.commit();
      return true;
    } catch (e) {
      print('Refund error: $e');
      return false;
    }
  }

  // Get all payments (for admin)
  Stream<List<PaymentModel>> getAllPayments() {
    return _firestore
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList());
  }

  // Get payments by provider
  Stream<List<PaymentModel>> getProviderPayments(String providerId) {
    return _firestore
        .collection('payments')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList());
  }

  // Get payment summary
  Future<Map<String, double>> getPaymentSummary() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: user.uid)
          .get();

      double totalSpent = 0;
      double totalRefunded = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final status = data['status'] ?? '';

        if (status == 'completed') {
          totalSpent += amount;
        } else if (status == 'refunded') {
          totalRefunded += amount;
        }
      }

      return {
        'totalSpent': totalSpent,
        'totalRefunded': totalRefunded,
        'netSpent': totalSpent - totalRefunded,
      };
    } catch (e) {
      print('Error getting payment summary: $e');
      return {};
    }
  }
}