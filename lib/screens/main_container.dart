import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'wallet_screen.dart';
import 'notifications.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  // Global keys to maintain navigation state within each tab
  final List<GlobalKey<NavigatorState>> _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTabNavigator(0, const HomeScreen()),
          _buildTabNavigator(1, const BookingsScreen()),
          _buildTabNavigator(2, const WalletScreen()),
          _buildTabNavigator(3, const NotificationsScreen()),
          _buildTabNavigator(4, const ProfileScreen()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index) {
            // Pop to root if the same tab is re-tapped
            _navKeys[index].currentState?.popUntil((r) => r.isFirst);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navKeys[index],
      onGenerateRoute: (route) => MaterialPageRoute(
        settings: route,
        builder: (context) => child,
      ),
    );
  }
}
