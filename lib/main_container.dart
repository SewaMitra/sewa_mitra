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
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/bookings') || location.startsWith('/provider/dashboard')) return 1;
    if (location.startsWith('/wallet') || location.startsWith('/provider/earnings') || location.startsWith('/admin/providers')) return 2;
    if (location.startsWith('/profile')) return _role == 'admin' ? 2 : 3;
    if (location.startsWith('/admin/users')) return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (_role) {
      case 'provider':
        switch (index) {
          case 0: context.go('/home'); break; // Maybe provider has a home too? or dashboard
          case 1: context.go('/provider/dashboard'); break;
          case 2: context.go('/provider/earnings'); break;
          case 3: context.go('/profile'); break;
        }
        break;
      case 'admin':
        switch (index) {
          case 0: context.go('/admin/users'); break;
          case 1: context.go('/admin/providers'); break;
          case 2: context.go('/profile'); break;
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
      case 'provider':
        return const [
          NavItem(icon: Icons.dashboard_rounded, label: 'Home'),
          NavItem(icon: Icons.assignment_rounded, label: 'Jobs'),
          NavItem(icon: Icons.payments_rounded, label: 'Earnings'),
          NavItem(icon: Icons.person_rounded, label: 'Profile'),
        ];
      case 'admin':
        return const [
          NavItem(icon: Icons.group_rounded, label: 'Users'),
          NavItem(icon: Icons.engineering_rounded, label: 'Providers'),
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
        items: navItems, role: '',
      ),
    );
  }
}
