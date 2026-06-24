import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String bookingId;
  final String serviceName;
  final String transactionId;
  final String method;
  final String bookingDate;
  final String bookingTime;

  const PaymentSuccessScreen({
    Key? key,
    required this.amount,
    required this.bookingId,
    required this.serviceName,
    required this.transactionId,
    required this.method,
    required this.bookingDate,
    required this.bookingTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Animation
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),

                // Success Title
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Amount and Method
                Text(
                  'Paid Rs. ${amount.toStringAsFixed(0)} via $method',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Transaction Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Transaction ID',
                        transactionId,
                        Icons.receipt,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Booking ID',
                        '#$bookingId',
                        Icons.bookmark,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Service',
                        serviceName,
                        Icons.build,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Date',
                        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                        Icons.calendar_today,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Payment Method',
                        method,
                        Icons.payment,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to home and remove all previous screens
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // View Invoice Button
                TextButton(
                  onPressed: () {
                    _showInvoiceDialog(context);
                  },
                  child: const Text(
                    'View Invoice',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt,
                  size: 50,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Invoice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                _buildInvoiceRow('Booking ID', '#$bookingId'),
                _buildInvoiceRow('Service', serviceName),
                _buildInvoiceRow('Amount', 'Rs. ${amount.toStringAsFixed(0)}'),
                _buildInvoiceRow('Payment Method', method),
                _buildInvoiceRow('Transaction ID', transactionId),
                _buildInvoiceRow('Date', DateFormat('dd MMM yyyy').format(DateTime.now())),
                const Divider(height: 24),
                _buildInvoiceRow(
                    'Total Paid', 'Rs. ${amount.toStringAsFixed(0)}', isTotal: true
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
