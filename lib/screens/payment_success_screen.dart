import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String method;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Success"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),

            const SizedBox(height: 20),

            Text("Booking ID: $bookingId"),
            Text("Amount: Rs. $amount"),
            Text("Method: $method"),
          ],
        ),
      ),
    );
  }
}