import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/verify_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/filter_sort_screen.dart';
import '../features/services/service_detail_page.dart';
import '../features/services/book_service.dart';
import '../features/services/date_and_time.dart';
import '../features/booking/bookings_screen.dart';
import '../features/booking/booking_confirmation.dart';
import '../features/payment/payment_screen.dart';
import '../features/payment/payment_success_screen.dart';
import '../features/payment/card_payment_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/wallet/add_money_screen.dart';
import '../features/wallet/send_money_screen.dart';
import '../features/wallet/transaction_screen.dart';
import '../features/notifications/notifications.dart';
import '../features/profile/profile_screen.dart';
import '../features/provider/join_provider_screen.dart';
import '../features/provider/provider_management_screen.dart';
import '../features/provider/earning_screen.dart';
import '../features/admin/user_management_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../main_container.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.matchedLocation;

      final isAuthPage = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password' ||
          location == '/splash' ||
          location == '/verify';

      // Not logged in → send to login (except auth pages)
      if (user == null) {
        return isAuthPage ? null : '/login';
      }

      // Logged-in user on auth pages → redirect to their home
      if (isAuthPage && location != '/splash' && location != '/verify') {
        return await _getHomeForUser(user.uid);
      }

      if (location == '/splash') {
        return await _getHomeForUser(user.uid);
      }

      // ── Role-based access control ──────────────────────────────────
      final role = await _getUserRole(user.uid);

      // Admin-only routes: block non-admins
      if (location.startsWith('/admin')) {
        if (role != 'admin') return '/home';
      }

      // User/customer-only routes: block admins from user screens
      // Admins should not wander into customer-facing pages
      const adminOnlyPaths = ['/admin'];
      const customerOnlyPaths = ['/home', '/bookings', '/wallet'];
      const providerOnlyPaths = ['/provider/earnings'];

      if (role == 'admin') {
        // Admins trying to go to customer-only routes → admin dashboard
        if (customerOnlyPaths.any((p) => location.startsWith(p))) {
          return '/admin/dashboard';
        }
      }

      if (role == 'customer') {
        // Customers trying to access admin routes → home (already covered above)
        // Customers trying to access provider-only routes → home
        if (providerOnlyPaths.any((p) => location.startsWith(p))) {
          return '/home';
        }
      }

      if (role == 'provider') {
        // Providers trying to go to admin routes → their dashboard
        if (location.startsWith('/admin')) {
          return '/provider/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(nextScreen: SizedBox()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify',
        name: 'verify',
        builder: (context, state) => const VerifyScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainContainer(child: child);
        },
        routes: [
          // ── Customer routes ──────────────────────────────────────────
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/bookings',
            name: 'bookings',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // ── Provider routes ─────────────────────────────────────────
          GoRoute(
            path: '/provider/dashboard',
            name: 'provider-dashboard',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: '/provider/earnings',
            name: 'provider-earnings',
            builder: (context, state) => const EarningScreen(),
          ),

          // ── Admin routes (guarded in top-level redirect) ────────────
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'admin-users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: '/admin/providers',
            name: 'admin-providers',
            builder: (context, state) => const ProviderManagementScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/service/:serviceId',
        name: 'service-detail',
        builder: (context, state) => const ServiceDetailPage(),
      ),
      GoRoute(
        path: '/book/:serviceId',
        name: 'book-service',
        builder: (context, state) => const BookServiceScreen(),
      ),
      GoRoute(
        path: '/datetime/:bookingId',
        name: 'date-time',
        builder: (context, state) => const DateTimeSelectionScreen(),
      ),
      GoRoute(
        path: '/payment/:bookingId',
        name: 'payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentScreen(
            amount: extra['amount'] ?? 0.0,
            bookingId: state.pathParameters['bookingId'] ?? '',
            serviceName: extra['serviceName'] ?? 'Service',
            date: extra['date'] ?? '',
            time: extra['time'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/payment-success',
        name: 'payment-success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentSuccessScreen(
            amount: extra['amount'] ?? 0.0,
            bookingId: extra['bookingId'] ?? '',
            serviceName: extra['serviceName'] ?? '',
            transactionId: extra['transactionId'] ?? '',
            method: extra['method'] ?? '',
            bookingDate: extra['bookingDate'] ?? '',
            bookingTime: extra['bookingTime'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/card-payment',
        name: 'card-payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CardPaymentScreen(
            amount: extra['amount'] ?? 0.0,
            bookingId: extra['bookingId'] ?? '',
            serviceName: extra['serviceName'] ?? '',
            date: extra['date'] ?? '',
            time: extra['time'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/booking/:bookingId',
        name: 'booking-confirm',
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        path: '/filter',
        name: 'filter',
        builder: (context, state) => const FilterSortScreen(),
      ),
      GoRoute(
        path: '/add-money',
        name: 'add-money',
        builder: (context, state) => const AddMoneyScreen(),
      ),
      GoRoute(
        path: '/send-money',
        name: 'send-money',
        builder: (context, state) => const SendMoneyScreen(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/provider/join',
        name: 'provider-join',
        builder: (context, state) => const JoinProviderScreen(),
      ),
    ],
  );

  static Future<String> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data()?['role'] ?? 'customer';
    } catch (_) {
      return 'customer';
    }
  }

  static Future<String> _getHomeForUser(String uid) async {
    final role = await _getUserRole(uid);
    switch (role) {
      case 'admin':
        return '/admin/dashboard';
      case 'provider':
        return '/provider/dashboard';
      default:
        return '/home';
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
