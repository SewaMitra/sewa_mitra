import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sewa_mitra/screens/auth_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  Timer? _checkTimer;
  bool _isResending = false;
  String? _resendMessage;

  @override
  void initState() {
    super.initState();
    // Poll every 4 seconds to check if the user clicked the link
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final verified = await AuthService.checkEmailVerified();
      if (verified && mounted) {
        _checkTimer?.cancel();
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _resendMessage = null;
    });

    final result = await AuthService.resendVerificationEmail();

    if (!mounted) return;
    setState(() {
      _isResending = false;
      _resendMessage = result.success
          ? 'Verification email resent! Check your inbox.'
          : result.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Verify your email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Icon(Icons.email_outlined, color: Colors.orange, size: 80),

            const SizedBox(height: 25),

            const Text(
              'Check your email',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              'We sent a verification link to\n$email\n\nClick the link to activate your account.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blueGrey, height: 1.6),
            ),

            const SizedBox(height: 30),

            const CircularProgressIndicator(color: Colors.orange),

            const SizedBox(height: 12),

            const Text(
              'Waiting for verification…',
              style: TextStyle(color: Colors.blueGrey),
            ),

            const SizedBox(height: 40),

            if (_resendMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _resendMessage!.contains('resent')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _resendMessage!.contains('resent')
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _resendMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _resendMessage!.contains('resent')
                        ? Colors.green.shade800
                        : Colors.red,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _isResending ? null : _resend,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isResending
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.orange,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Resend verification email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () async {
                await AuthService.signOut();
                if (mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Use a different account',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
