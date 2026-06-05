// payment_screen.dart - improved version

import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:sewa_mitra/screens/payment_method_selector.dart';
import 'package:sewa_mitra/screens/payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String bookingId;
  final String serviceName;

  const PaymentScreen({
    required this.amount,
    required this.bookingId,
    required this.serviceName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? selectedMethod;
  bool isLoading = false;

  Future<void> processPayment() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? transactionId;

      switch (selectedMethod!.name) {
        case 'eSewa':
          transactionId = await payWithESewa();
          break;
        case 'Khalti':
          transactionId = await payWithKhalti();
          break;
        case 'Bank Transfer':
          transactionId = await showBankTransferDialog();
          break;
        case 'Cash on Service':
          transactionId = 'CASH_${DateTime.now().millisecondsSinceEpoch}';
          break;
      }

      if (transactionId != null) {
        // Navigate to success screen with REAL transaction ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              amount: widget.amount ?? 0.0,
              bookingId: widget.bookingId ?? 'N/A',
              serviceName: widget.serviceName ?? 'Service',
              transactionId: transactionId ?? '',
              method: selectedMethod!.name,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String> payWithESewa() async {
    // For demo – in real app, call eSewa API
    Completer<String> completer = Completer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('eSewa Payment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Amount: Rs. ${widget.amount}'),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'eSewa PIN'),
            obscureText: true,
            onChanged: (value) {},
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simulate API call
              String fakeTxId = 'ESEWA_${DateTime.now().millisecondsSinceEpoch}';
              Navigator.pop(context);
              completer.complete(fakeTxId);
            },
            child: Text('Pay Rs. ${widget.amount}'),
          ),
        ],
      ),
    );

    return completer.future;
  }

  Future<String> payWithKhalti() async {
    // Similar to eSewa – show PIN entry dialog
    Completer<String> completer = Completer();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Khalti Payment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Amount: Rs. ${widget.amount}'),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Khalti MPIN'),
            obscureText: true,
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String fakeTxId = 'KHALTI_${DateTime.now().millisecondsSinceEpoch}';
              Navigator.pop(context);
              completer.complete(fakeTxId);
            },
            child: Text('Confirm Payment'),
          ),
        ],
      ),
    );

    return completer.future;
  }

  Future<String?> showBankTransferDialog() async {
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Bank Transfer Instructions'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Transfer Rs. ${widget.amount} to:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Bank: Nabil Bank'),
          Text('Account Name: Sewa Mitra Pvt Ltd'),
          Text('Account Number: 1234567890'),
          Text('IFSC: NABILNP123'),
          SizedBox(height: 16),
          Divider(),
          Text('After transfer, upload receipt:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Implement image picker
              Navigator.pop(context, 'BANK_${DateTime.now().millisecondsSinceEpoch}');
            },
            icon: Icon(Icons.upload_file),
            label: Text('Upload Receipt'),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking summary card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Total due', style: TextStyle(fontSize: 16)),
                          Text('Rs. ${widget.amount}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ]),
                        SizedBox(height: 8),
                        Text('${widget.serviceName} · Booking #${widget.bookingId}', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                // Payment method grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    final isSelected = selectedMethod?.name == method.name;
                    return GestureDetector(
                      onTap: () => setState(() => selectedMethod = method),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? method.color.withOpacity(0.1) : Colors.white,
                          border: Border.all(color: isSelected ? method.color : Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.payment, size: 32, color: isSelected ? method.color : Colors.grey),
                          SizedBox(height: 8),
                          Text(method.name, style: TextStyle(fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
          // Bottom fixed button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
              child: ElevatedButton(
                onPressed: isLoading ? null : processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Proceed to Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}