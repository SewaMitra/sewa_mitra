import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'other_screens.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  // Global keys to maintain navigation state within tabs
  final GlobalKey<NavigatorState> _homeNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Navigator(
            key: _homeNavKey,
            onGenerateRoute: (route) => MaterialPageRoute(
              settings: route,
              builder: (context) => const HomeScreen(),
            ),
          ),
          const BookingsScreen(),
          const WalletScreen(),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index && index == 0) {
            // Pop to root if Home tab is re-tapped
            _homeNavKey.currentState?.popUntil((r) => r.isFirst);
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
