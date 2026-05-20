import 'package:flutter/material.dart';
import 'card_payment_screen.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String serviceName;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Booking ID: $bookingId"),
            Text("Amount: Rs. $amount"),
            Text("Service: $serviceName"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardPaymentScreen(
                      bookingId: bookingId,
                      amount: amount,
                    ),
                  ),
                );
              },
              child: const Text("Card Payment"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentSuccessScreen(
                      bookingId: bookingId,
                      amount: amount,
                      method: "Cash",
                    ),
                  ),
                );
              },
              child: const Text("Cash Payment"),
            ),
          ],
        ),
      ),
    );
  }
}