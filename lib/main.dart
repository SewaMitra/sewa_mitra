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
      home: const PaymentScreen(
        amount: 1200.0,
        bookingId: '4821',
        serviceName: 'Electric Pro Services',
      ), // Change this to test different screens
      debugShowCheckedModeBanner: false,
    );
  }
}