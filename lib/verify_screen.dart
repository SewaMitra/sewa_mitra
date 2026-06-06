import 'package:flutter/material.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Verify your identity'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),

        child: Column(
          children: [

            const SizedBox(height: 70),

            Container(
              height: 80,
              width: 80,

              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.lock,
                color: Colors.orange,
                size: 40,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              '2-Step verification',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'We sent a 6-digit code to\n+977 98XXXXXXXX',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 35),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: List.generate(
                6,
                    (index) => SizedBox(
                  width: 45,

                  child: TextField(
                    maxLength: 1,
                    textAlign: TextAlign.center,

                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Resend code in 0:00',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  'Verify & Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade200),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.security,
                    color: Colors.green,
                    size: 35,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [

                        Text(
                          'Secure session token',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Successful verification creates a secure JWT session.',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}