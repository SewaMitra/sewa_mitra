import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PaymentScreen(
        bookingId: "BK101",
        amount: 2500,
        serviceName: "Cleaning Service",
      ),
    );
  }
}