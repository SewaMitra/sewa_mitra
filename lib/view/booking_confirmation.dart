import 'package:flutter/material.dart';
import 'notifications.dart';
import 'book_service.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stepper indicator
                      Row(
                        children: [
                          _buildStepCircle(1, 'Select\nService', true),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: const Color(0xFFFF8A00),
                            ),
                          ),
                          _buildStepCircle(2, 'Date &\nTime', true),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: const Color(0xFFFF8A00),
                            ),
                          ),
                          _buildStepCircle(3, 'Confirm\nBooking', true),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Success Icon and Title
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFFFF8A00),
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Booking Confirmed',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Booking Reference: #BK-20260511',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Booking Details Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E5EA)),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Service', 'Electrical Repair'),
                            _buildDivider(),
                            _buildDetailRow('Provider', 'Electric Pro'),
                            _buildDivider(),
                            _buildDetailRow('Date', 'Mon, 11 May 2026'),
                            _buildDivider(),
                            _buildDetailRow('Time', '11:00 AM'),
                            _buildDivider(),
                            _buildDetailRow('Address', 'Thamel, Kathmandu'),
                            _buildDivider(),
                            _buildDetailRow('Amount', 'Rs. 500', isBold: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.edit_calendar,
                              label: 'Reschedule',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reschedule feature coming soon'),
                                    backgroundColor: Color(0xFFFF8A00),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.track_changes,
                              label: 'Tracker',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tracker feature coming soon'),
                                    backgroundColor: Color(0xFFFF8A00),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.download,
                              label: 'Download\nReceipt',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Downloading receipt...'),
                                    backgroundColor: Color(0xFFFF8A00),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(context, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF8E8E93),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? const Color(0xFFFF8A00) : const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE5E5EA),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5EA)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF8A00),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFF8A00) : Colors.white,
            border: Border.all(
              color: isActive ? const Color(0xFFFF8A00) : const Color(0xFFE5E5EA),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF8E8E93),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFFFF8A00) : const Color(0xFFC6C6C8),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E5EA), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF8A00),
        unselectedItemColor: const Color(0xFF8E8E93),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
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
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BookServiceScreen()),
              );
              break;
            case 1: // Bookings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You are already on Bookings'),
                  backgroundColor: Color(0xFFFF8A00),
                ),
              );
              break;
            case 2: // Wallet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet feature coming soon'),
                  backgroundColor: Color(0xFFFF8A00),
                ),
              );
              break;
            case 3: // Notifications
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
              break;
            case 4: // Profile
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