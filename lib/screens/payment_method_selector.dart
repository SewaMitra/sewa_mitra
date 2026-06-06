import 'package:flutter/material.dart';

class PaymentMethod {
  final String name;
  final String iconPath;
  final Color color;

  PaymentMethod({required this.name, required this.iconPath, required this.color});
}

final List<PaymentMethod> paymentMethods = [
  PaymentMethod(name: 'eSewa', iconPath: 'assets/esewa.png', color: Colors.green),
  PaymentMethod(name: 'Khalti', iconPath: 'assets/khalti.png', color: Colors.purple),
  PaymentMethod(name: 'Bank Transfer', iconPath: 'assets/bank.png', color: Colors.blue),
  PaymentMethod(name: 'Cash on Service', iconPath: 'assets/cash.png', color: Colors.orange),
];