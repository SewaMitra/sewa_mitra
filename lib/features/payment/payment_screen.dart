import 'package:flutter/material.dart';
import 'payment_success_screen.dart';
import 'card_payment_screen.dart';
import '../../shared/models/models.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String bookingId;
  final String serviceName;
  final String date;
  final String time;

  const PaymentScreen({
    required this.amount,
    required this.bookingId,
    required this.serviceName,
    required this.date,
    required this.time,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedMethod;

  void processPayment() {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if (selectedMethod == 'Credit Card') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardPaymentScreen(
            amount: widget.amount,
            bookingId: widget.bookingId,
            serviceName: widget.serviceName,
            date: widget.date,
            time: widget.time,
          ),
        ),
      );
      return;
    }

    if (selectedMethod == 'Wallet Balance') {
      if (!WalletData.subtractMoney(widget.amount)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient Wallet Balance')),
        );
        return;
      }
    }

    // Add booking data before navigating
    final newBooking = Booking(
      id: widget.bookingId,
      serviceName: widget.serviceName,
      providerName: 'Professional Provider',
      date: widget.date,
      time: widget.time,
      address: 'Kathmandu, Nepal',
      amount: widget.amount,
    );
    BookingData.addBooking(newBooking);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: widget.amount,
          bookingId: widget.bookingId,
          serviceName: widget.serviceName,
          transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          method: selectedMethod!,
          bookingDate: widget.date,
          bookingTime: widget.time,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFFF6B35);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment details section - EXACT match
          // Payment details section - with grey background and white text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800], // Dark grey background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total due',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70, // Light white/grey for label
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${widget.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for amount
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.serviceName} · Booking #${widget.bookingId}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white60, // Light white for subtitle
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Select payment method text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select payment method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment methods list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMethodCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Wallet Balance',
                  subtitle: 'Pay using your Sewa Mitra wallet',
                  value: 'Wallet Balance',
                  primaryOrange: primaryOrange,
                ),
                _buildMethodCard(
                  icon: Icons.credit_card,
                  title: 'Credit / Debit Card',
                  subtitle: 'Visa, Mastercard accepted',
                  value: 'Credit Card',
                  primaryOrange: primaryOrange,
                ),
                _buildMethodCard(
                  icon: Icons.wallet,
                  title: 'eSewa',
                  subtitle: 'Mobile wallet',
                  value: 'eSewa',
                  primaryOrange: primaryOrange,
                ),
                _buildMethodCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Khalti',
                  subtitle: 'Digital wallet',
                  value: 'Khalti',
                  primaryOrange: primaryOrange,
                ),
                _buildMethodCard(
                  icon: Icons.account_balance,
                  title: 'Bank Transfer',
                  subtitle: 'NABIL, NIC Asia...',
                  value: 'Bank Transfer',
                  primaryOrange: primaryOrange,
                ),
                _buildMethodCard(
                  icon: Icons.money,
                  title: 'Cash on service',
                  subtitle: 'Pay after completion',
                  value: 'Cash on Service',
                  primaryOrange: primaryOrange,
                ),
              ],
            ),
          ),

          // Proceed to Pay button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color primaryOrange,
  }) {
    final isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? primaryOrange.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: primaryOrange,  // All icons always orangecu
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? primaryOrange : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryOrange,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}