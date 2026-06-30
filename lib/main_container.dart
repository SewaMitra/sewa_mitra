import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'shared/widgets/custom_bottom_nav_bar.dart';
import 'viewmodels/user_viewmodel.dart';

class MainContainer extends StatefulWidget {
  final Widget child;
  const MainContainer({super.key, required this.child});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  String _role = 'customer';
  bool _isAdminLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final role = await AuthService.getCachedRole();
    if (mounted) {
      setState(() {
        _role = role;
        _isAdminLoading = false;
      });
    }
  }

  int _calculateSelectedIndex(BuildContext context, String currentMode) {
    final String location = GoRouterState.of(context).matchedLocation;
    
    if (_role == 'admin') {
      if (location.startsWith('/admin/users')) return 0;
      if (location.startsWith('/admin/providers')) return 1;
      if (location.startsWith('/profile')) return 2;
      return 0;
    }

    if (currentMode == 'provider') {
      if (location.startsWith('/provider/dashboard')) return 0;
      if (location.startsWith('/bookings')) return 1;
      if (location.startsWith('/provider/earnings')) return 2;
      if (location.startsWith('/profile')) return 3;
      return 0;
    }

    // Customer Mode
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, String currentMode) {
    if (_role == 'admin') {
      switch (index) {
        case 0: context.go('/admin/users'); break;
        case 1: context.go('/admin/providers'); break;
        case 2: context.go('/profile'); break;
      }
      return;
    }

    if (currentMode == 'provider') {
      switch (index) {
        case 0: context.go('/provider/dashboard'); break;
        case 1: context.go('/bookings'); break;
        case 2: context.go('/provider/earnings'); break;
        case 3: context.go('/profile'); break;
      }
      return;
    }

    // Customer mode
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/bookings'); break;
      case 2: context.go('/wallet'); break;
      case 3: context.go('/profile'); break;
    }
  }

  List<NavItem> _getNavItems(String currentMode) {
    if (_role == 'admin') {
      return const [
        NavItem(icon: Icons.group_rounded, label: 'Users'),
        NavItem(icon: Icons.engineering_rounded, label: 'Providers'),
        NavItem(icon: Icons.person_rounded, label: 'Profile'),
      ];
    }

    if (currentMode == 'provider') {
      return const [
        NavItem(icon: Icons.dashboard_rounded, label: 'Home'),
        NavItem(icon: Icons.assignment_rounded, label: 'Jobs'),
        NavItem(icon: Icons.payments_rounded, label: 'Earnings'),
        NavItem(icon: Icons.person_rounded, label: 'Profile'),
      ];
    }

    return const [
      NavItem(icon: Icons.home_rounded, label: 'Home'),
      NavItem(icon: Icons.calendar_today_rounded, label: 'Bookings'),
      NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
      NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    
    if (_isAdminLoading || userVM.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = _getNavItems(userVM.activeMode);
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _calculateSelectedIndex(context, userVM.activeMode),
        onTap: (index) => _onItemTapped(index, context, userVM.activeMode),
        items: navItems,
      ),
    );
  }
}
