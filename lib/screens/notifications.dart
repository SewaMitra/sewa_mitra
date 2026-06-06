import 'package:flutter/material.dart';
import 'book_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marked all as read'),
                          backgroundColor: Color(0xFFFF8A00),
                        ),
                      );
                    },
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF8A00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Live Updates Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _LiveUpdatesToggle(),
            ),

            const SizedBox(height: 20),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNotificationCard(
                    context: context,
                    icon: Icons.directions_car,
                    iconColor: const Color(0xFFFF8A00),
                    title: 'Provider is on the way!',
                    message: 'Electric Pro will arrive in 15 minutes. Track live location.',
                    time: 'Just now',
                    isLiveUpdate: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tracking live location...'),
                          backgroundColor: Color(0xFFFF8A00),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationCard(
                    context: context,
                    icon: Icons.check_circle,
                    iconColor: const Color(0xFF34C759),
                    title: 'Booking Confirmed',
                    message: 'Your booking #BK-20260511 has been confirmed for 11:00 AM Today',
                    time: '2 min ago',
                    isLiveUpdate: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('View booking details'),
                          backgroundColor: Color(0xFFFF8A00),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationCard(
                    context: context,
                    icon: Icons.payment,
                    iconColor: const Color(0xFF34C759),
                    title: 'Payment Received',
                    message: 'Rs 500 paid via eSewa.',
                    time: '3 min ago',
                    isLiveUpdate: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('View payment details'),
                          backgroundColor: Color(0xFFFF8A00),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(context, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isLiveUpdate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5EA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      if (isLiveUpdate)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8A00).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A00),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C6C70),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5EA), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF8A00),
        unselectedItemColor: const Color(0xFF8E8E93),
        selectedLabelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500),
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const BookServiceScreen()),
              );
              break;
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View your bookings coming soon'),
                  backgroundColor: Color(0xFFFF8A00),
                ),
              );
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet feature coming soon'),
                  backgroundColor: Color(0xFFFF8A00),
                ),
              );
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You are already on Notifications'),
                  backgroundColor: Color(0xFFFF8A00),
                ),
              );
              break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile feature coming soon'),
                  backgroundColor: Color(0xFFFF8A00),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

// Extracted to StatefulWidget so the switch actually works
class _LiveUpdatesToggle extends StatefulWidget {
  @override
  State<_LiveUpdatesToggle> createState() => _LiveUpdatesToggleState();
}

class _LiveUpdatesToggleState extends State<_LiveUpdatesToggle> {
  bool _liveUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A00).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Live Updates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          Row(
            children: [
              Text(
                _liveUpdates ? 'On' : 'Off',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFF8A00),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _liveUpdates,
                onChanged: (bool value) {
                  setState(() => _liveUpdates = value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(value ? 'Live Updates On' : 'Live Updates Off'),
                      backgroundColor: const Color(0xFFFF8A00),
                    ),
                  );
                },
                activeColor: const Color(0xFFFF8A00),
                activeTrackColor:
                    const Color(0xFFFF8A00).withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
