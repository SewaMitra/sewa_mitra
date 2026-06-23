import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/backend_models.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's wallet
  Future<Wallet?> getWallet() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('wallets').doc(user.uid).get();

      if (doc.exists) {
        return Wallet.fromFirestore(doc.data()!, user.uid);
      } else {
        return await _createWallet(user.uid);
      }
    } catch (e) {
      print('Error getting wallet: $e');
      return null;
    }
  }

  // Create wallet for user
  Future<Wallet> _createWallet(String userId) async {
    final wallet = Wallet(
      userId: userId,
      balance: 0.0,
      currency: 'USD',
      lastUpdated: DateTime.now(),
    );

    await _firestore.collection('wallets').doc(userId).set(wallet.toFirestore());
    return wallet;
  }

  // Get balance
  Future<double> getBalance() async {
    final wallet = await getWallet();
    return wallet?.balance ?? 0.0;
  }

  // Add money to wallet
  Future<bool> addMoney({
    required double amount,
    String? description,
    String? paymentId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final batch = _firestore.batch();
      final walletRef = _firestore.collection('wallets').doc(user.uid);

      // Update wallet balance
      batch.update(walletRef, {
        'balance': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      final transactionRef = _firestore.collection('transactions').doc();
      final transaction = TransactionModel(
        id: transactionRef.id,
        userId: user.uid,
        type: 'add_money',
        amount: amount,
        status: 'completed',
        description: description ?? 'Added money to wallet',
        senderId: user.uid,
        paymentId: paymentId,
        createdAt: DateTime.now(),
      );
      batch.set(transactionRef, transaction.toFirestore());

      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding money: $e');
      return false;
    }
  }

  // Deduct money from wallet (for payments)
  Future<bool> deductBalance({
    required double amount,
    String? description,
    String? bookingId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if sufficient balance
      final currentBalance = await getBalance();
      if (currentBalance < amount) {
        return false;
      }

      final batch = _firestore.batch();
      final walletRef = _firestore.collection('wallets').doc(user.uid);

      // Update wallet balance
      batch.update(walletRef, {
        'balance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      final transactionRef = _firestore.collection('transactions').doc();
      final transaction = TransactionModel(
        id: transactionRef.id,
        userId: user.uid,
        type: 'payment',
        amount: -amount,
        status: 'completed',
        description: description ?? 'Payment for booking',
        senderId: user.uid,
        bookingId: bookingId,
        createdAt: DateTime.now(),
      );
      batch.set(transactionRef, transaction.toFirestore());

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deducting balance: $e');
      return false;
    }
  }

  // Send money to another user
  Future<bool> sendMoney({
    required String receiverId,
    required double amount,
    String? description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if sender has enough balance
      final senderBalance = await getBalance();
      if (senderBalance < amount) {
        return false;
      }

      // Check if receiver exists
      final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) {
        return false;
      }

      final batch = _firestore.batch();

      // Update sender's wallet
      final senderRef = _firestore.collection('wallets').doc(user.uid);
      batch.update(senderRef, {
        'balance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update receiver's wallet
      final receiverRef = _firestore.collection('wallets').doc(receiverId);
      batch.update(receiverRef, {
        'balance': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Create sender transaction
      final senderTransactionRef = _firestore.collection('transactions').doc();
      final senderTransaction = TransactionModel(
        id: senderTransactionRef.id,
        userId: user.uid,
        type: 'send_money',
        amount: -amount,
        status: 'completed',
        description: description ?? 'Sent money to user',
        senderId: user.uid,
        receiverId: receiverId,
        createdAt: DateTime.now(),
      );
      batch.set(senderTransactionRef, senderTransaction.toFirestore());

      // Create receiver transaction
      final receiverTransactionRef = _firestore.collection('transactions').doc();
      final receiverTransaction = TransactionModel(
        id: receiverTransactionRef.id,
        userId: receiverId,
        type: 'receive_money',
        amount: amount,
        status: 'completed',
        description: description ?? 'Received money from user',
        senderId: user.uid,
        receiverId: receiverId,
        createdAt: DateTime.now(),
      );
      batch.set(receiverTransactionRef, receiverTransaction.toFirestore());

      await batch.commit();
      return true;
    } catch (e) {
      print('Error sending money: $e');
      return false;
    }
  }

  // Get transaction history
  Stream<List<TransactionModel>> getTransactionHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList());
  }

  // Get transaction history for a specific user (admin)
  Stream<List<TransactionModel>> getUserTransactionHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList());
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final doc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting transaction: $e');
      return null;
    }
  }

  // Check if user has sufficient balance
  Future<bool> hasSufficientBalance(double amount) async {
    final balance = await getBalance();
    return balance >= amount;
  }
}