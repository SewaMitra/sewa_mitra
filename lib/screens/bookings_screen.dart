import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
          ),
        ),
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.lightOrange,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppTheme.primaryOrange, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book a service to see it here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
