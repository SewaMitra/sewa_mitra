import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

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
      body: ValueListenableBuilder<List<Booking>>(
        valueListenable: BookingData.bookingsNotifier,
        builder: (context, bookings, child) {
          return bookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.serviceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppTheme.greyText),
              const SizedBox(width: 8),
              Text(
                booking.providerName,
                style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.greyText),
              const SizedBox(width: 8),
              Text(
                '${booking.date} at ${booking.time}',
                style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${booking.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
