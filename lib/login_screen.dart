import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isPhoneLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),

      appBar: AppBar(
        title: const Text('Welcome back'),
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),

        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 30),

              Container(
                height: 70,
                width: 70,

                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Icon(
                  Icons.build,
                  color: Colors.white,
                  size: 35,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sign in to book trusted\nprofessionals near you',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),

              const SizedBox(height: 30),

              // EMAIL / PHONE SWITCH

              Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isPhoneLogin = false;
                        });
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),

                        decoration: BoxDecoration(
                          color: !isPhoneLogin
                              ? Colors.orange
                              : Colors.white,

                          borderRadius: BorderRadius.circular(14),

                          border: Border.all(
                            color: Colors.orange,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            'Email',
                            style: TextStyle(
                              color: !isPhoneLogin
                                  ? Colors.white
                                  : Colors.orange,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isPhoneLogin = true;
                        });
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),

                        decoration: BoxDecoration(
                          color: isPhoneLogin
                              ? Colors.orange
                              : Colors.white,

                          borderRadius: BorderRadius.circular(14),

                          border: Border.all(
                            color: Colors.orange,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            'Phone',
                            style: TextStyle(
                              color: isPhoneLogin
                                  ? Colors.white
                                  : Colors.orange,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

git               const SizedBox(height: 25),

              // PHONE LOGIN

              if (isPhoneLogin) ...[

                TextField(
                  keyboardType: TextInputType.phone,

                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+977 98XXXXXXXX',
                    prefixIcon: const Icon(Icons.phone),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: () {},

                    child: const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              // EMAIL LOGIN

              if (!isPhoneLogin) ...[

                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email address',
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
                    hintText: 'Enter password',

                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: const Icon(
                      Icons.visibility_outlined,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: () {},

                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}