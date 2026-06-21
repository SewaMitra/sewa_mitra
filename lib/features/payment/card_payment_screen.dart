import 'package:flutter/material.dart';
import 'payment_success_screen.dart';
import '../../shared/models/models.dart';

class CardPaymentScreen extends StatefulWidget {
  final double amount;
  final String bookingId;
  final String serviceName;
  final String date;
  final String time;

  const CardPaymentScreen({
    required this.amount,
    required this.bookingId,
    required this.serviceName,
    required this.date,
    required this.time,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void processPayment() {
    if (_formKey.currentState!.validate()) {
      // Add booking data before navigating
      final newBooking = Booking(
        id: widget.bookingId,
        serviceName: widget.serviceName,
        providerName: 'Professional Provider',
        date: widget.date,
        time: widget.time,
        address: 'Kathmandu, Nepal',
        amount: widget.amount,
      );
      BookingData.addBooking(newBooking);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            bookingId: widget.bookingId,
            serviceName: widget.serviceName,
            transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
            method: 'Credit Card',
            bookingDate: widget.date,
            bookingTime: widget.time,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFFF6B35);
    final lightOrange = primaryOrange.withOpacity(0.1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Card Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Amount to Pay'),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${widget.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.replaceAll(' ', '').length < 16) {
                    return 'Enter valid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryOrange, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 5) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryOrange, width: 2),
                        ),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Holder
              TextFormField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Card Holder Name',
                  hintText: 'SALMAN ANSARI',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter card holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}