import 'package:flutter/material.dart';
import 'payment_success_screen.dart';
import 'card_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String bookingId;
  final String serviceName;

  const PaymentScreen({
    required this.amount,
    required this.bookingId,
    required this.serviceName,
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
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: widget.amount,
          bookingId: widget.bookingId,
          serviceName: widget.serviceName,
          transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          method: selectedMethod!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFFF6B35);
    final lightOrange = primaryOrange.withOpacity(0.1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Payment details card - Orange theme
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: lightOrange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total due',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${widget.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.serviceName} · Booking #${widget.bookingId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Payment methods list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Select payment method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                _buildMethodCard(
                  icon: Icons.credit_card,
                  title: 'Credit / Debit Card',
                  subtitle: 'Visa, Mastercard accepted',
                  value: 'Credit Card',
                  primaryOrange: primaryOrange,
                  lightOrange: lightOrange,
                ),

                _buildMethodCard(
                  icon: Icons.wallet,
                  title: 'eSewa',
                  subtitle: 'Mobile wallet',
                  value: 'eSewa',
                  primaryOrange: primaryOrange,
                  lightOrange: lightOrange,
                ),

                _buildMethodCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Khalti',
                  subtitle: 'Digital wallet',
                  value: 'Khalti',
                  primaryOrange: primaryOrange,
                  lightOrange: lightOrange,
                ),

                _buildMethodCard(
                  icon: Icons.account_balance,
                  title: 'Bank Transfer',
                  subtitle: 'NABIL, NIC Asia...',
                  value: 'Bank Transfer',
                  primaryOrange: primaryOrange,
                  lightOrange: lightOrange,
                ),

                _buildMethodCard(
                  icon: Icons.money,
                  title: 'Cash on service',
                  subtitle: 'Pay after completion',
                  value: 'Cash on Service',
                  primaryOrange: primaryOrange,
                  lightOrange: lightOrange,
                ),
              ],
            ),
          ),

          // Proceed to Pay button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
    required Color lightOrange,
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
          color: isSelected ? lightOrange : Colors.white,
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
              color: isSelected ? primaryOrange : Colors.grey.shade600,
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