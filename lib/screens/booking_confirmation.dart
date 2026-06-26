import 'package:flutter/material.dart';
import '../models/models.dart';
import 'home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C1C1E), size: 20),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: const Text(
          'Booking Confirmation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                                color: const Color(0xFFFF8A00)),
                          ),
                          _buildStepCircle(2, 'Date &\nTime', true),
                          Expanded(
                            child: Container(
                                height: 2,
                                color: const Color(0xFFFF8A00)),
                          ),
                          _buildStepCircle(3, 'Confirm\nBooking', true),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Success Icon and Title
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFF8A00),
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Booking Confirmed',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Booking Reference: #${booking.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
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
                          border:
                              Border.all(color: const Color(0xFFE5E5EA)),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Service', booking.serviceName),
                            _buildDivider(),
                            _buildDetailRow('Provider', booking.providerName),
                            _buildDivider(),
                            _buildDetailRow('Date', booking.date),
                            _buildDivider(),
                            _buildDetailRow('Time', booking.time),
                            _buildDivider(),
                            _buildDetailRow('Address', booking.address),
                            _buildDivider(),
                            _buildDetailRow('Amount', 'Rs. ${booking.amount}',
                                isBold: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              icon: Icons.edit_calendar,
                              label: 'Reschedule',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Reschedule feature coming soon'),
                                    backgroundColor: Color(0xFFFF8A00),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              icon: Icons.track_changes,
                              label: 'Tracker',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Tracker feature coming soon'),
                                    backgroundColor: Color(0xFFFF8A00),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              context: context,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFE5E5EA));
  }

  Widget _buildActionButton({
    required BuildContext context,
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
            Icon(icon, color: const Color(0xFFFF8A00), size: 24),
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
              color: isActive
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFFE5E5EA),
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
            color: isActive
                ? const Color(0xFFFF8A00)
                : const Color(0xFFC6C6C8),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
