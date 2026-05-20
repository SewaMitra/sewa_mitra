import 'package:flutter/material.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {

  final Map<String, double> weeklyData = {
    "Mon": 2400,
    "Tue": 1200,
    "Wed": 3100,
    "Thu": 1800,
    "Fri": 2900,
    "Sat": 3800,
    "Sun": 1600,
  };

  @override
  Widget build(BuildContext context) {

    double maxValue = weeklyData.values.reduce(
          (a, b) => a > b ? a : b,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
        title: const Text("Earnings Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Total Earnings Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Total Earnings",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Rs. 48,200",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "May 2026 · Provider View",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),

                    child: const LinearProgressIndicator(
                      value: 0.72,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "72% of monthly target",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              children: [

                _statCard(
                  "Completed Jobs",
                  "34",
                  const Color(0xFFFFF3E0),
                  const Color(0xFFFF8C00),
                ),

                _statCard(
                  "Pending Payout",
                  "Rs. 3,200",
                  Colors.green.shade50,
                  Colors.green,
                ),

                _statCard(
                  "Avg per Job",
                  "Rs. 1,418",
                  Colors.blue.shade50,
                  Colors.blue,
                ),

                _statCard(
                  "Refunds Issued",
                  "Rs. 500",
                  Colors.red.shade50,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "This Week",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 10),

            // Weekly Chart
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Column(
                children: weeklyData.entries.map((entry) {

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),

                    child: Row(
                      children: [

                        SizedBox(
                          width: 40,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),

                            child: LinearProgressIndicator(
                              value: entry.value / maxValue,
                              minHeight: 10,

                              backgroundColor:
                              const Color(0xFFFFE0B2),

                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF8C00),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        SizedBox(
                          width: 70,

                          child: Text(
                            "Rs. ${entry.value.toInt()}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String label,
      String value,
      Color bg,
      Color textColor,
      ) {

    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}