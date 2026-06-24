import 'package:cloud_firestore/cloud_firestore.dart';

// ============= WALLET MODELS =============
class Wallet {
  final String userId;
  double balance;
  final String currency;
  final DateTime lastUpdated;

  Wallet({
    required this.userId,
    required this.balance,
    this.currency = 'USD',
    required this.lastUpdated,
  });

  factory Wallet.fromFirestore(Map<String, dynamic> data, String userId) {
    return Wallet(
      userId: userId,
      balance: (data['balance'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

// ============= TRANSACTION MODELS =============
class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'add_money', 'send_money', 'receive', 'payment', 'refund', 'withdrawal'
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final String? description;
  final String? senderId;
  final String? receiverId;
  final String? bookingId;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.senderId,
    this.receiverId,
    this.bookingId,
    this.paymentId,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      description: data['description'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      bookingId: data['bookingId'],
      paymentId: data['paymentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'status': status,
      'description': description,
      'senderId': senderId,
      'receiverId': receiverId,
      'bookingId': bookingId,
      'paymentId': paymentId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// ============= PAYMENT MODELS =============
class PaymentModel {
  final String id;
  final String userId;
  final String bookingId;
  final double amount;
  final String currency;
  final String method; // 'card', 'wallet', 'cash', 'esewa', 'khalti'
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String? cardId;
  final String? transactionId;
  final String? providerId;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.cardId,
    this.transactionId,
    this.providerId,
    required this.createdAt,
    this.completedAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      method: data['method'] ?? 'card',
      status: data['status'] ?? 'pending',
      cardId: data['cardId'],
      transactionId: data['transactionId'],
      providerId: data['providerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'method': method,
      'status': status,
      'cardId': cardId,
      'transactionId': transactionId,
      'providerId': providerId,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': completedAt != null ? FieldValue.serverTimestamp() : null,
    };
  }
}

// ============= SAVED CARD MODELS =============
class SavedCardModel {
  final String id;
  final String userId;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cardType;
  final bool isDefault;
  final String? stripePaymentMethodId;

  SavedCardModel({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cardType,
    required this.isDefault,
    this.stripePaymentMethodId,
  });

  factory SavedCardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedCardModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      cardNumber: data['cardNumber'] ?? '',
      cardHolderName: data['cardHolderName'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      cardType: data['cardType'] ?? 'visa',
      isDefault: data['isDefault'] ?? false,
      stripePaymentMethodId: data['stripePaymentMethodId'],
    );
  }
}

// ============= PROVIDER MODELS =============
class ProviderModel {
  final String id;
  final String userId;
  final String businessName;
  final String description;
  final List<String> services;
  final String category;
  double rating;
  int totalReviews;
  bool isActive;
  final bool isVerified;
  final String? profileImage;
  final List<String> images;
  final String address;
  final String phone;
  final String email;
  final double basePrice;
  double completionRate;
  int totalJobs;
  double totalEarnings;
  final DateTime createdAt;
  DateTime? updatedAt;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.description,
    required this.services,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.isActive,
    required this.isVerified,
    this.profileImage,
    required this.images,
    required this.address,
    required this.phone,
    required this.email,
    required this.basePrice,
    required this.completionRate,
    required this.totalJobs,
    required this.totalEarnings,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      businessName: data['businessName'] ?? '',
      description: data['description'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      isActive: data['isActive'] ?? false,
      isVerified: data['isVerified'] ?? false,
      profileImage: data['profileImage'],
      images: List<String>.from(data['images'] ?? []),
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      completionRate: (data['completionRate'] ?? 0).toDouble(),
      totalJobs: data['totalJobs'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

// ============= PROVIDER APPLICATION MODELS =============
class ProviderApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String businessName;
  final String description;
  final List<String> services;
  final String category;
  final String phone;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final bool documentsUploaded;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  ProviderApplicationModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.businessName,
    required this.description,
    required this.services,
    required this.category,
    required this.phone,
    required this.status,
    this.rejectionReason,
    required this.documentsUploaded,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory ProviderApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderApplicationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      businessName: data['businessName'] ?? '',
      description: data['description'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      category: data['category'] ?? '',
      phone: data['phone'] ?? '',
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
      documentsUploaded: data['documentsUploaded'] ?? false,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

// ============= EARNING MODELS =============
class EarningModel {
  final String id;
  final String providerId;
  final String bookingId;
  final double amount;
  final double fee;
  final double netAmount;
  final String status; // 'pending', 'available', 'withdrawn'
  final String? paymentId;
  final DateTime earnedAt;
  final DateTime? withdrawnAt;

  EarningModel({
    required this.id,
    required this.providerId,
    required this.bookingId,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.status,
    this.paymentId,
    required this.earnedAt,
    this.withdrawnAt,
  });

  factory EarningModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EarningModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      fee: (data['fee'] ?? 0).toDouble(),
      netAmount: (data['netAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentId: data['paymentId'],
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
      withdrawnAt: data['withdrawnAt'] != null
          ? (data['withdrawnAt'] as Timestamp).toDate()
          : null,
    );
  }
}