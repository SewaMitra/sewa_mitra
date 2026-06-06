import 'package:flutter/material.dart';
import 'book_service.dart';

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
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF8A00),
          secondary: Color(0xFFFF8A00),
        ),
        useMaterial3: true,
      ),
      home: const BookServiceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}