import 'package:flutter/material.dart';

class ServiceCategory {
  final String name;
  final String iconPath;
  final IconData? icon;

  const ServiceCategory({
    required this.name,
    this.iconPath = '',
    this.icon,
  });
}

class ServiceProvider {
  final String name;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String currency;
  final String imagePath;
  final String specialty;

  const ServiceProvider({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.currency,
    required this.imagePath,
    required this.specialty,
  });
}

class Booking {
  final String id;
  final String serviceName;
  final String providerName;
  final String date;
  final String time;
  final String address;
  final double amount;
  final String status;

  Booking({
    required this.id,
    required this.serviceName,
    required this.providerName,
    required this.date,
    required this.time,
    required this.address,
    required this.amount,
    this.status = 'Confirmed',
  });
}

class BookingData {
  static final ValueNotifier<List<Booking>> bookingsNotifier = ValueNotifier<List<Booking>>([]);

  static List<Booking> get bookings => bookingsNotifier.value;

  static void addBooking(Booking booking) {
    bookingsNotifier.value = [...bookingsNotifier.value, booking];
  }
}

class WalletData {
  static final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(2450.0);

  static double get balance => balanceNotifier.value;

  static void addMoney(double amount) {
    balanceNotifier.value += amount;
  }

  static bool subtractMoney(double amount) {
    if (balanceNotifier.value >= amount) {
      balanceNotifier.value -= amount;
      return true;
    }
    return false;
  }
}
