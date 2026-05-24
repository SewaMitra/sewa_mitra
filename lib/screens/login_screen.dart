// lib/screens/login_screen.dart
//
// Three login methods matching SewaMitra's design:
//   Tab 1 — Phone OTP
//   Tab 2 — Email + Password
//   Tab 3 — Google (one tap button, always visible)
//
// Wires directly into AuthService from auth_service.dart.
// On success → navigates to MainNavigation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSuccess() {
    // _AuthGate in main.dart listens to authStateChanges and automatically
    // replaces LoginScreen with MainNavigation upon sign-in — no push needed.
    // If LoginScreen was opened standalone (e.g. after logout), pop back instead.
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: Stack(
        children: [
          // ── Decorative orbs ───────────────────────────────────────────
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange.withOpacity(0.07),
              ),
            ),
          ),

          // ── Main scroll content ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ── Logo + title ────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryOrange.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_repair_service_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Sewa',
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.darkText,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              TextSpan(
                                text: 'Mitra',
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryOrange,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your trusted home service partner',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Welcome text ────────────────────────────────────────
                  Text(
                    'Welcome back 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.greyText,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Tab bar ─────────────────────────────────────────────
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.greyText,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.all(4),
                      tabs: const [
                        Tab(text: 'Phone'),
                        Tab(text: 'Email'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Tab views ───────────────────────────────────────────
                  SizedBox(
                    // Fixed height so SingleChildScrollView works with TabBarView
                    height: 340,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _PhoneOtpTab(onSuccess: _onSuccess),
                        _EmailTab(onSuccess: _onSuccess),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Divider ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Google button ───────────────────────────────────────
                  _GoogleSignInButton(onSuccess: _onSuccess),

                  const SizedBox(height: 32),

                  // ── Sign up prompt ──────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppTheme.greyText),
                            ),
                            TextSpan(
                              text: 'Sign up',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB 1 — PHONE OTP
// ════════════════════════════════════════════════════════════════════════════
class _PhoneOtpTab extends StatefulWidget {
  final VoidCallback onSuccess;
  const _PhoneOtpTab({required this.onSuccess});

  @override
  State<_PhoneOtpTab> createState() => _PhoneOtpTabState();
}

class _PhoneOtpTabState extends State<_PhoneOtpTab> {
  final _auth = AuthService();
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  String? _verificationId;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = '+977${_phoneCtrl.text.trim()}';
    if (_phoneCtrl.text.trim().length < 10) {
      setState(() => _error = 'Enter a valid 10-digit number');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await _auth.sendOtp(
      phoneNumber: phone,
      onCodeSent: (vid) {
        setState(() { _verificationId = vid; _otpSent = true; _loading = false; });
      },
      onError: (e) {
        setState(() { _error = e; _loading = false; });
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.verifyOtp(verificationId: _verificationId!, otp: otp);
      widget.onSuccess();
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  void _onOtpDigit(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _otpFocus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_otpSent) ...[
          // ── Phone input ───────────────────────────────────────────────
          _FieldLabel('Mobile Number'),
          const SizedBox(height: 6),
          Row(
            children: [
              // Country code badge
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    const Text('🇳🇵', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text('+977', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.darkText)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StyledField(
                  controller: _phoneCtrl,
                  hint: '98XXXXXXXX',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_error != null) _ErrorText(_error!),
          if (_error != null) const SizedBox(height: 12),
          _OrangeButton(
            label: 'Send OTP',
            loading: _loading,
            onTap: _sendOtp,
          ),
        ] else ...[
          // ── OTP input ─────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'Enter the 6-digit code sent to',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.greyText),
                ),
                Text(
                  '+977 ${_phoneCtrl.text}',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.darkText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 6 OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 46,
                height: 54,
                child: TextFormField(
                  controller: _otpCtrl[i],
                  focusNode: _otpFocus[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.darkText),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppTheme.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                    ),
                  ),
                  onChanged: (v) => _onOtpDigit(v, i),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          if (_error != null) _ErrorText(_error!),
          if (_error != null) const SizedBox(height: 12),
          _OrangeButton(label: 'Verify OTP', loading: _loading, onTap: _verifyOtp),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () => setState(() { _otpSent = false; _error = null; for (final c in _otpCtrl) c.clear(); }),
              child: Text(
                'Change number',
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primaryOrange, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB 2 — EMAIL + PASSWORD
// ════════════════════════════════════════════════════════════════════════════
class _EmailTab extends StatefulWidget {
  final VoidCallback onSuccess;
  const _EmailTab({required this.onSuccess});

  @override
  State<_EmailTab> createState() => _EmailTabState();
}

class _EmailTabState extends State<_EmailTab> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signInWithEmail(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      widget.onSuccess();
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email first');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(_emailCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${_emailCtrl.text.trim()}'),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Email Address'),
        const SizedBox(height: 6),
        _StyledField(
          controller: _emailCtrl,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Password'),
        const SizedBox(height: 6),
        _StyledField(
          controller: _passCtrl,
          hint: '••••••••',
          obscureText: _obscure,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.greyText, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _forgotPassword,
            child: Text(
              'Forgot password?',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.primaryOrange, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_error != null) _ErrorText(_error!),
        if (_error != null) const SizedBox(height: 12),
        _OrangeButton(label: 'Sign In', loading: _loading, onTap: _login),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  GOOGLE SIGN-IN BUTTON
// ════════════════════════════════════════════════════════════════════════════
class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback onSuccess;
  const _GoogleSignInButton({required this.onSuccess});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _auth.signInWithGoogle();
      if (result != null) widget.onSuccess();
      else setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _loading ? null : _signIn,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: _loading
                ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryOrange)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google G logo drawn with text (no asset needed)
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Text(
                          'G',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          _ErrorText(_error!),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  REGISTER SCREEN
// ════════════════════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.registerWithEmail(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        // _AuthGate in main.dart listens to authStateChanges and automatically
        // navigates to MainNavigation after registration — no manual push needed.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Create Account',
                        style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.darkText)),
                    const SizedBox(height: 4),
                    Text('Join SewaMitra today',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.greyText)),
                    const SizedBox(height: 28),

                    _FieldLabel('Full Name'),
                    const SizedBox(height: 6),
                    _StyledValidatedField(
                      controller: _nameCtrl,
                      hint: 'Ram Shrestha',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Email Address'),
                    const SizedBox(height: 6),
                    _StyledValidatedField(
                      controller: _emailCtrl,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Password'),
                    const SizedBox(height: 6),
                    _StyledValidatedField(
                      controller: _passCtrl,
                      hint: '••••••••',
                      obscureText: _obscurePass,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppTheme.greyText, size: 20),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Confirm Password'),
                    const SizedBox(height: 6),
                    _StyledValidatedField(
                      controller: _confirmCtrl,
                      hint: '••••••••',
                      obscureText: _obscureConfirm,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppTheme.greyText, size: 20),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                    ),

                    const SizedBox(height: 24),
                    if (_error != null) _ErrorText(_error!),
                    if (_error != null) const SizedBox(height: 12),

                    _OrangeButton(label: 'Create Account', loading: _loading, onTap: _register),

                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.greyText),
                              ),
                              TextSpan(
                                text: 'Sign in',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED SMALL WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.greyText));
  }
}

// Unvalidated field (used in login tabs)
class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const _StyledField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: AppTheme.greyText.withOpacity(0.6)),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppTheme.greyText, size: 20)
              : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5)),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// Validated field (used in RegisterScreen)
class _StyledValidatedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _StyledValidatedField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: AppTheme.greyText.withOpacity(0.6)),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppTheme.greyText, size: 20)
              : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _OrangeButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _OrangeButton({required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: loading ? AppTheme.primaryOrange.withOpacity(0.7) : AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}
