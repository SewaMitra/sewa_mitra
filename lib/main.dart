import 'package:flutter/material.dart';
import 'register_screen.dart';
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
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const PaymentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}