import 'package:flutter/material.dart';

class CardPaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;

  const CardPaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Payment"),
      ),
      body: Center(
        child: Text(
          "Pay Rs. $amount\nBooking: $bookingId",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}