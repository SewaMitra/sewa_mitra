import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';
import 'screens/card_payment_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/earning_screen.dart';
import 'screens/join_provider_screen.dart';
import 'screens/provider_management_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/user_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Sewa Mitra',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF6B35),
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          primary: const Color(0xFFFF6B35),
        ),
      ),
      home: const PaymentScreen(amount: 0.0, bookingId: '', serviceName: '',), // Change this to test different screens
      debugShowCheckedModeBanner: false,
    );
  }
}