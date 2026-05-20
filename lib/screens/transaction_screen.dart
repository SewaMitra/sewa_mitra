import 'package:flutter/material.dart';

class Transaction {
  final String id, serviceName, date, method;
  final double amount;
  final bool isCredit;
  final String status; // "Paid", "Refunded", "Pending", "Failed"

  Transaction({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.method,
    required this.amount,
    required this.isCredit,
    required this.status,
  });
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final List<Transaction> transactions = [
    Transaction(id: "T001", serviceName: "Electric Pro Services",
        date: "10 May", method: "Card", amount: 1200, isCredit: false, status: "Paid"),
    Transaction(id: "T002", serviceName: "Refund · Plumber",
        date: "8 May", method: "eSewa", amount: 500, isCredit: true, status: "Refunded"),
    Transaction(id: "T003", serviceName: "Clean Home Nepal",
        date: "5 May", method: "Khalti", amount: 800, isCredit: false, status: "Paid"),
    Transaction(id: "T004", serviceName: "ArcticCool AC Repair",
        date: "2 May", method: "Cash", amount: 2000, isCredit: false, status: "Pending"),
  ];

  @override
  Widget build(BuildContext context) {
    double totalPaid = transactions
        .where((t) => !t.isCredit && t.status == "Paid")
        .fold(0, (sum, t) => sum + t.amount);
    double totalRefunded = transactions
        .where((t) => t.status == "Refunded")
        .fold(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
        title: const Text("Transactions"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _statCard("Total Paid",
                    "Rs. ${totalPaid.toInt()}", const Color(0xFFFFF3E0), const Color(0xFFFF8C00))),
                const SizedBox(width: 10),
                Expanded(child: _statCard("Refunded",
                    "Rs. ${totalRefunded.toInt()}", Colors.green.shade50, Colors.green)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent Transactions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _transactionItem(transactions[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _transactionItem(Transaction tx) {
    Color statusColor;
    Color statusBg;
    switch (tx.status) {
      case "Paid": statusColor = Colors.green; statusBg = Colors.green.shade50; break;
      case "Refunded": statusColor = Colors.blue; statusBg = Colors.blue.shade50; break;
      case "Pending": statusColor = Colors.orange; statusBg = Colors.orange.shade50; break;
      default: statusColor = Colors.red; statusBg = Colors.red.shade50;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tx.isCredit ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(
              tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: tx.isCredit ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.serviceName,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text("${tx.date} · ${tx.method}",
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${tx.isCredit ? '+' : '-'} Rs. ${tx.amount.toInt()}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tx.isCredit ? Colors.green : Colors.red,
                    fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(tx.status,
                    style: TextStyle(color: statusColor, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}