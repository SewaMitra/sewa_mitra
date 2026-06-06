import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Create account'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),

        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Ram Bahadur',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a strong password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Text('At least 8 characters'),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Text('One uppercase letter'),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Text('One number or symbol'),
                ],
              ),

              const SizedBox(height: 25),

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
                      Icons.shield,
                      color: Colors.green,
                      size: 35,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: const [

                          Text(
                            'End-to-end encrypted',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Your data is protected with AES-256 encryption.',
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
                    'Create account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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