import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/onboarding_widgets.dart';
import 'sign_up_screen.dart';

const _navy = Color(0xFF060814);
const _purple = Color(0xFF955CFF);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;
  late final Animation<double> _tagline;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addStatusListener(_onStatus);
    _entrance = _controller.drive(
      CurveTween(curve: const Interval(0, 0.42, curve: Curves.easeOutCubic)),
    );
    _tagline = _controller.drive(
      CurveTween(curve: const Interval(0.32, 0.65, curve: Curves.easeOutCubic)),
    );
    _controller.forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = animation.drive(
            CurveTween(curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: curved.drive(
                Tween(begin: const Offset(0, 0.045), end: Offset.zero),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LuxuryBackdrop(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoSize = (constraints.maxWidth * 0.62)
                .clamp(0.0, constraints.maxHeight * 0.48)
                .clamp(0.0, 300.0);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _entrance,
                      child: ScaleTransition(
                        scale: _entrance.drive(Tween(begin: 0.86, end: 1.0)),
                        child: AnimatedBuilder(
                          animation: _controller,
                          child: Image.asset(
                            'assets/images/milex_logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            semanticLabel: 'MileX logo',
                          ),
                          builder: (context, child) {
                            final sweep = const Interval(
                              0.4,
                              0.82,
                              curve: Curves.easeOutCubic,
                            ).transform(_controller.value);
                            // Transparent shader outside the band leaves the
                            // original logo untouched before and after the sweep.
                            return ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment(-3 + 6 * sweep, -0.4),
                                end: Alignment(-2.2 + 6 * sweep, 0.4),
                                colors: const [
                                  Colors.transparent,
                                  Color(0x38955CFF),
                                  Colors.transparent,
                                ],
                                stops: const [0, 0.5, 1],
                              ).createShader(bounds),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _tagline,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Drive more. Worry less.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFAAA6BA),
                            fontSize: 15,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LuxuryBackdrop extends StatelessWidget {
  const LuxuryBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _navy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _navy,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 0.85,
              colors: [Color(0xFF211238), _navy],
            ),
          ),
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}

/// Temporary landing screen until the supplied car photograph and design
/// reference are available. No substitute car artwork is used.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuxuryBackdrop(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/milex_logo.png',
                  width: 160,
                  semanticLabel: 'MileX logo',
                ),
                const SizedBox(height: 32),
                const Text(
                  'Find your perfect ride',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your journey, your way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _purple, fontSize: 16),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Get Started',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SignUpScreen(),
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
}
