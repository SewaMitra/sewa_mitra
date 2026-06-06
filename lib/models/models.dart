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
  static final List<Booking> bookings = [];

  static void addBooking(Booking booking) {
    bookings.add(booking);
  }
}
