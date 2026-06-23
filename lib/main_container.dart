import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'shared/widgets/custom_bottom_nav_bar.dart';

class MainContainer extends StatefulWidget {
  final Widget child;
  const MainContainer({super.key, required this.child});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  String _role = 'customer';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final profile = await AuthService.getUserProfile();
    if (mounted) {
      setState(() {
        _role = profile?['role'] ?? 'customer';
        _isLoading = false;
      });
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    switch (_role) {
      case 'admin':
        if (location.startsWith('/admin/dashboard')) return 0;
        if (location.startsWith('/admin/users')) return 1;
        if (location.startsWith('/admin/providers')) return 2;
        if (location.startsWith('/profile')) return 3;
        return 0;

      case 'provider':
        if (location.startsWith('/home')) return 0;
        if (location.startsWith('/provider/dashboard') ||
            location.startsWith('/bookings')) return 1;
        if (location.startsWith('/provider/earnings')) return 2;
        if (location.startsWith('/profile')) return 3;
        return 0;

      case 'customer':
      default:
        if (location.startsWith('/home')) return 0;
        if (location.startsWith('/bookings')) return 1;
        if (location.startsWith('/wallet')) return 2;
        if (location.startsWith('/profile')) return 3;
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (_role) {
      case 'admin':
        switch (index) {
          case 0: context.go('/admin/dashboard'); break;
          case 1: context.go('/admin/users'); break;
          case 2: context.go('/admin/providers'); break;
          case 3: context.go('/profile'); break;
        }
        break;

      case 'provider':
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/provider/dashboard'); break;
          case 2: context.go('/provider/earnings'); break;
          case 3: context.go('/profile'); break;
        }
        break;

      case 'customer':
      default:
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/bookings'); break;
          case 2: context.go('/wallet'); break;
          case 3: context.go('/profile'); break;
        }
        break;
    }
  }

  List<NavItem> _getNavItems() {
    switch (_role) {
      case 'admin':
        return const [
          NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          NavItem(icon: Icons.group_rounded, label: 'Users'),
          NavItem(icon: Icons.engineering_rounded, label: 'Providers'),
          NavItem(icon: Icons.person_rounded, label: 'Profile'),
        ];

      case 'provider':
        return const [
          NavItem(icon: Icons.home_rounded, label: 'Home'),
          NavItem(icon: Icons.assignment_rounded, label: 'Jobs'),
          NavItem(icon: Icons.payments_rounded, label: 'Earnings'),
          NavItem(icon: Icons.person_rounded, label: 'Profile'),
        ];

      case 'customer':
      default:
        return const [
          NavItem(icon: Icons.home_rounded, label: 'Home'),
          NavItem(icon: Icons.calendar_today_rounded, label: 'Bookings'),
          NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
          NavItem(icon: Icons.person_rounded, label: 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = _getNavItems();

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: navItems,
      ),
    );
  }
}
