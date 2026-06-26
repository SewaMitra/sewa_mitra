import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sewa_mitra/shared/models/backend_models.dart';

class ProviderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Apply to become a provider
  Future<Map<String, dynamic>> applyAsProvider({
    required String fullName,
    required String businessName,
    required String description,
    required List<String> services,
    required String category,
    required String phone,
    required bool documentsUploaded,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      // Check if already applied — filter client-side to avoid composite index
      final existingApps = await _firestore
          .collection('provider_applications')
          .where('userId', isEqualTo: user.uid)
          .get();

      final alreadyApplied = existingApps.docs.any((doc) {
        final status = doc.data()['status'];
        return status == 'pending' || status == 'approved';
      });

      if (alreadyApplied) {
        return {'success': false, 'error': 'You already have a pending application'};
      }

      // Check if already a provider
      final existingProvider = await _firestore
          .collection('providers')
          .doc(user.uid)
          .get();

      if (existingProvider.exists) {
        return {'success': false, 'error': 'You are already a provider'};
      }

      // Create application
      final applicationRef = _firestore.collection('provider_applications').doc();
      final application = ProviderApplicationModel(
        id: applicationRef.id,
        userId: user.uid,
        fullName: fullName,
        businessName: businessName,
        description: description,
        services: services,
        category: category,
        phone: phone,
        status: 'pending',
        documentsUploaded: documentsUploaded,
        submittedAt: DateTime.now(),
      );

      await applicationRef.set({
        'userId': application.userId,
        'fullName': application.fullName,
        'businessName': application.businessName,
        'description': application.description,
        'services': application.services,
        'category': application.category,
        'phone': application.phone,
        'status': application.status,
        'documentsUploaded': application.documentsUploaded,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Update user providerApplicationStatus
      await _firestore.collection('users').doc(user.uid).update({
        'providerApplicationStatus': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'applicationId': applicationRef.id,
        'message': 'Application submitted successfully',
      };
    } catch (e) {
      print('Error applying as provider: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get provider application status
  Future<ProviderApplicationModel?> getApplicationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // orderBy('submittedAt') alone — no composite index needed
      final snapshot = await _firestore
          .collection('provider_applications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ProviderApplicationModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting application: $e');
      return null;
    }
  }

  // Get provider profile
  Future<ProviderModel?> getProviderProfile(String providerId) async {
    try {
      final doc = await _firestore
          .collection('providers')
          .doc(providerId)
          .get();

      if (!doc.exists) return null;
      return ProviderModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting provider: $e');
      return null;
    }
  }

  // Get current user's provider profile
  Future<ProviderModel?> getMyProviderProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('providers')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      return ProviderModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting my provider: $e');
      return null;
    }
  }

  // Update provider profile
  Future<bool> updateProviderProfile(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('providers').doc(user.uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating provider: $e');
      return false;
    }
  }

  // Get all providers — client-side isActive filter to avoid composite index
  Stream<List<ProviderModel>> getAllProviders({bool activeOnly = true}) {
    return _firestore
        .collection('providers')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      var providers = snapshot.docs
          .map((doc) => ProviderModel.fromFirestore(doc))
          .toList();
      if (activeOnly) {
        providers = providers.where((p) => p.isActive).toList();
      }
      return providers;
    });
  }

  // Get providers by category — client-side isActive filter to avoid composite index
  Stream<List<ProviderModel>> getProvidersByCategory(String category) {
    return _firestore
        .collection('providers')
        .where('category', isEqualTo: category)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProviderModel.fromFirestore(doc))
            .where((p) => p.isActive)
            .toList());
  }

  // Search providers
  Stream<List<ProviderModel>> searchProviders(String query) {
    // Note: For production, use Algolia or ElasticSearch
    return _firestore
        .collection('providers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProviderModel.fromFirestore(doc))
            .where((provider) =>
                provider.isActive &&
                (provider.businessName.toLowerCase().contains(query.toLowerCase()) ||
                    provider.description.toLowerCase().contains(query.toLowerCase()) ||
                    provider.category.toLowerCase().contains(query.toLowerCase())))
            .toList());
  }

  // Add earning to provider
  Future<void> addEarning({
    required String providerId,
    required String bookingId,
    required double amount,
    String? paymentId,
  }) async {
    try {
      final fee = amount * 0.2; // 20% platform fee
      final netAmount = amount * 0.8; // 80% to provider

      final earningRef = _firestore.collection('earnings').doc();
      final earning = EarningModel(
        id: earningRef.id,
        providerId: providerId,
        bookingId: bookingId,
        amount: amount,
        fee: fee,
        netAmount: netAmount,
        status: 'pending',
        paymentId: paymentId,
        earnedAt: DateTime.now(),
      );

      await earningRef.set({
        'providerId': earning.providerId,
        'bookingId': earning.bookingId,
        'amount': earning.amount,
        'fee': earning.fee,
        'netAmount': earning.netAmount,
        'status': earning.status,
        'paymentId': earning.paymentId,
        'earnedAt': FieldValue.serverTimestamp(),
      });

      // Update provider total earnings
      await _firestore.collection('providers').doc(providerId).update({
        'totalEarnings': FieldValue.increment(netAmount),
        'totalJobs': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding earning: $e');
    }
  }

  // Admin - Approve provider application
  Future<bool> approveApplication(String applicationId) async {
    try {
      final batch = _firestore.batch();

      // Get application
      final appDoc = await _firestore
          .collection('provider_applications')
          .doc(applicationId)
          .get();

      if (!appDoc.exists) return false;

      final appData = appDoc.data()!;
      final userId = appData['userId'];
      final businessName = appData['businessName'] ?? '';
      final description = appData['description'] ?? '';
      final services = List<String>.from(appData['services'] ?? []);
      final category = appData['category'] ?? '';
      final phone = appData['phone'] ?? '';
      final address = appData['address'] ?? '';

      // Update application status
      batch.update(
        _firestore.collection('provider_applications').doc(applicationId),
        {
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );

      // Create provider profile
      final provider = ProviderModel(
        id: userId,
        userId: userId,
        businessName: businessName,
        description: description,
        services: services,
        category: category,
        rating: 0.0,
        totalReviews: 0,
        isActive: true,
        isVerified: false,
        profileImage: null,
        images: [],
        address: address,
        phone: phone,
        email: appData['email'] ?? '',
        basePrice: (appData['basePrice'] ?? 0).toDouble(),
        completionRate: 0.0,
        totalJobs: 0,
        totalEarnings: 0.0,
        createdAt: DateTime.now(),
      );

      batch.set(
        _firestore.collection('providers').doc(userId),
        {
          'userId': provider.userId,
          'businessName': provider.businessName,
          'description': provider.description,
          'services': provider.services,
          'category': provider.category,
          'rating': provider.rating,
          'totalReviews': provider.totalReviews,
          'isActive': provider.isActive,
          'isVerified': provider.isVerified,
          'profileImage': provider.profileImage,
          'images': provider.images,
          'address': provider.address,
          'phone': provider.phone,
          'email': provider.email,
          'basePrice': provider.basePrice,
          'completionRate': provider.completionRate,
          'totalJobs': provider.totalJobs,
          'totalEarnings': provider.totalEarnings,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // Update user role
      batch.update(
        _firestore.collection('users').doc(userId),
        {
          'role': 'provider',
          'providerApplicationStatus': 'approved',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error approving application: $e');
      return false;
    }
  }

  // Admin - Reject provider application
  Future<bool> rejectApplication(String applicationId, String reason) async {
    try {
      final appDoc = await _firestore
          .collection('provider_applications')
          .doc(applicationId)
          .get();

      if (!appDoc.exists) return false;

      final userId = appDoc.data()!['userId'];

      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('provider_applications').doc(applicationId),
        {
          'status': 'rejected',
          'rejectionReason': reason,
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _firestore.collection('users').doc(userId),
        {
          'providerApplicationStatus': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error rejecting application: $e');
      return false;
    }
  }

  // Get all applications (for admin) — client-side status filter to avoid composite index
  Stream<List<ProviderApplicationModel>> getAllApplications({String? status}) {
    return _firestore
        .collection('provider_applications')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var apps = snapshot.docs
          .map((doc) => ProviderApplicationModel.fromFirestore(doc))
          .toList();
      if (status != null) {
        apps = apps.where((a) => a.status == status).toList();
      }
      return apps;
    });
  }

  // Get provider earnings
  Stream<List<EarningModel>> getProviderEarnings(String providerId) {
    return _firestore
        .collection('earnings')
        .where('providerId', isEqualTo: providerId)
        .orderBy('earnedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EarningModel.fromFirestore(doc))
            .toList());
  }

  // Get earning summary for provider
  Future<Map<String, double>> getEarningSummary(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('earnings')
          .where('providerId', isEqualTo: providerId)
          .get();

      double totalEarnings = 0;
      double availableBalance = 0;
      double pendingBalance = 0;
      double totalWithdrawn = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['netAmount'] ?? data['amount'] ?? 0).toDouble();
        final status = data['status'] ?? 'pending';

        totalEarnings += amount;

        if (status == 'available') {
          availableBalance += amount;
        } else if (status == 'pending') {
          pendingBalance += amount;
        } else if (status == 'withdrawn') {
          totalWithdrawn += amount;
        }
      }

      return {
        'totalEarnings': totalEarnings,
        'availableBalance': availableBalance,
        'pendingBalance': pendingBalance,
        'totalWithdrawn': totalWithdrawn,
      };
    } catch (e) {
      print('Error getting earning summary: $e');
      return {
        'totalEarnings': 0,
        'availableBalance': 0,
        'pendingBalance': 0,
        'totalWithdrawn': 0,
      };
    }
  }

  // Withdraw earnings
  Future<bool> withdrawEarnings(String providerId, double amount) async {
    try {
      final summary = await getEarningSummary(providerId);
      if ((summary['availableBalance'] ?? 0) < amount) {
        return false;
      }

      final batch = _firestore.batch();

      final snapshot = await _firestore
          .collection('earnings')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'available')
          .get();

      double totalWithdrawn = 0;
      for (var doc in snapshot.docs) {
        if (totalWithdrawn >= amount) break;

        final data = doc.data();
        final earningAmount = (data['netAmount'] ?? data['amount'] ?? 0).toDouble();
        final remainingToWithdraw = amount - totalWithdrawn;

        if (earningAmount <= remainingToWithdraw) {
          batch.update(doc.reference, {
            'status': 'withdrawn',
            'withdrawnAt': FieldValue.serverTimestamp(),
          });
          totalWithdrawn += earningAmount;
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error withdrawing earnings: $e');
      return false;
    }
  }

  // Admin - Suspend provider
  Future<bool> suspendProvider(String providerId, String reason) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'isActive': false,
        'suspensionReason': reason,
        'suspendedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(providerId).update({
        'role': 'suspended',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error suspending provider: $e');
      return false;
    }
  }

  // Admin - Restore provider
  Future<bool> restoreProvider(String providerId) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'isActive': true,
        'suspensionReason': null,
        'restoredAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(providerId).update({
        'role': 'provider',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error restoring provider: $e');
      return false;
    }
  }

  // Get provider stats (for dashboard)
  Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    try {
      final provider = await getProviderProfile(providerId);
      if (provider == null) return {};

      final earnings = await getEarningSummary(providerId);

      return {
        'businessName': provider.businessName,
        'rating': provider.rating,
        'totalReviews': provider.totalReviews,
        'totalJobs': provider.totalJobs,
        'completionRate': provider.completionRate,
        'totalEarnings': earnings['totalEarnings'] ?? 0,
        'availableBalance': earnings['availableBalance'] ?? 0,
        'pendingBalance': earnings['pendingBalance'] ?? 0,
      };
    } catch (e) {
      print('Error getting provider stats: $e');
      return {};
    }
  }
}
