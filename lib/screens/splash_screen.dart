import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _dotController;
  late final AnimationController _fadeOutController;

  // ── Animations ───────────────────────────────────────────────────────────
  late final Animation<double> _circleScale1;
  late final Animation<double> _circleScale2;
  late final Animation<double> _circleOpacity1;
  late final Animation<double> _circleOpacity2;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _subtitleOpacity;

  late final Animation<double> _dot1Opacity;
  late final Animation<double> _dot2Opacity;
  late final Animation<double> _dot3Opacity;

  late final Animation<double> _screenFadeOut;

  @override
  void initState() {
    super.initState();

    // Background ripple circles
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _circleScale1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _circleScale2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _circleOpacity1 = Tween<double>(begin: 0.18, end: 0.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _circleOpacity2 = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Logo pop + slide up
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Text fade-in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    // Loading dots
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dot1Opacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );
    _dot2Opacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );
    _dot3Opacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.66, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Fade out before navigation
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _screenFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInCubic),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1. Background ripple
    await _bgController.forward();
    // 2. Logo pop in
    await _logoController.forward();
    // 3. Text fades in
    await _textController.forward();
    // 4. Hold for a moment
    await Future.delayed(const Duration(milliseconds: 1400));
    // 5. Stop dots, fade screen out, navigate
    _dotController.stop();
    await _fadeOutController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _dotController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _textController,
          _dotController,
          _fadeOutController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _screenFadeOut,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Ripple circle 1 ──────────────────────────────────────
                Transform.scale(
                  scale: _circleScale1.value,
                  child: Opacity(
                    opacity: _circleOpacity1.value.clamp(0.0, 1.0),
                    child: Container(
                      width: size.width * 1.6,
                      height: size.width * 1.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                ),

                // ── Ripple circle 2 ──────────────────────────────────────
                Transform.scale(
                  scale: _circleScale2.value,
                  child: Opacity(
                    opacity: _circleOpacity2.value.clamp(0.0, 1.0),
                    child: Container(
                      width: size.width * 2.2,
                      height: size.width * 2.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                ),

                // ── Decorative background blobs ──────────────────────────
                Positioned(
                  top: size.height * 0.06,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryOrange.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.10,
                  right: 20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryOrange.withOpacity(0.09),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.10,
                  left: -40,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryOrange.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.18,
                  right: 10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryOrange.withOpacity(0.08),
                    ),
                  ),
                ),

                // ── Main content ─────────────────────────────────────────
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo icon box with gradient ──────────────────────
                    SlideTransition(
                      position: _logoSlide,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryOrange,
                                  AppTheme.primaryOrange.withRed(
                                    (AppTheme.primaryOrange.red * 0.78).round(),
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryOrange.withOpacity(0.40),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: AppTheme.primaryOrange.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Subtle inner highlight
                                Positioned(
                                  top: 8,
                                  left: 10,
                                  child: Container(
                                    width: 50,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/icon/sew.jpeg',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── App name: SewaMitra ──────────────────────────────
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineOpacity,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Sewa',
                                style: GoogleFonts.poppins(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.darkText,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              TextSpan(
                                text: 'Mitra',
                                style: GoogleFonts.poppins(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryOrange,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Nepali tagline ───────────────────────────────────
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        'घरमै सेवा, भरोसाको साथ',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.darkText.withOpacity(0.75),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ── English sub-tagline ──────────────────────────────
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        'Trusted home services, at your doorstep',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.greyText,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // ── Loading dots ─────────────────────────────────────
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LoadingDot(opacity: _dot1Opacity.value, size: 9),
                          const SizedBox(width: 8),
                          _LoadingDot(opacity: _dot2Opacity.value, size: 9),
                          const SizedBox(width: 8),
                          _LoadingDot(opacity: _dot3Opacity.value, size: 9),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Bottom tagline ───────────────────────────────────────
                Positioned(
                  bottom: 36,
                  child: FadeTransition(
                    opacity: _subtitleOpacity,
                    child: Column(
                      children: [
                        Text(
                          'भरोसेमन्द · छिटो · व्यावसायिक',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.greyText.withOpacity(0.55),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trusted · Fast · Professional',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.greyText.withOpacity(0.40),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Loading dot widget ────────────────────────────────────────────────────────
class _LoadingDot extends StatelessWidget {
  final double opacity;
  final double size;
  const _LoadingDot({required this.opacity, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.2, 1.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
