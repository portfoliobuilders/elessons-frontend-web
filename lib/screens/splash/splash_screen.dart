import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/gtec_logo.dart';

/// Full-screen animated splash screen displaying the highlighted G-TEC logo
/// with smooth entrance, glow, scale, and subtle float animations while initializing
/// providers and restoring auth state in the background.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    // Entrance Animation (Fade + Scale + Initial Glow)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    // Continuous Subtle Pulse & Float Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowAnim = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _floatAnim = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start Animation & Initialization Pipeline
    _startSequence();
  }

  Future<void> _startSequence() async {
    // 1. Play entrance animation
    _entranceController.forward();

    // 2. Start looping subtle pulse & float after entrance starts
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // 3. Perform App Initialization & Session Restoration
    final Stopwatch stopwatch = Stopwatch()..start();
    final AuthProvider auth = context.read<AuthProvider>();
    await auth.bootstrap();

    // 4. Ensure minimum splash presentation time (2.2 seconds) for smooth UX
    const int minSplashMs = 2200;
    final int elapsedMs = stopwatch.elapsedMilliseconds;
    if (elapsedMs < minSplashMs) {
      await Future<void>.delayed(
        Duration(milliseconds: minSplashMs - elapsedMs),
      );
    }

    if (!mounted) return;

    // 5. Determine Destination & Navigate
    final String nextRoute;
    if (auth.isAuthenticated) {
      nextRoute = auth.isOnboarded ? AppRoutes.home : AppRoutes.onboardBoard;
    } else {
      nextRoute = AppRoutes.welcome;
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _fadeAnim,
            _scaleAnim,
            _glowAnim,
            _floatAnim,
          ]),
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Premium Soft Ambient Glow behind the logo
                      Container(
                        width: 220,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF0096C7).withValues(
                                alpha: 0.22 * _glowAnim.value,
                              ),
                              blurRadius: 60,
                              spreadRadius: 24,
                            ),
                            BoxShadow(
                              color: AppColors.navy.withValues(
                                alpha: 0.08 * _glowAnim.value,
                              ),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),

                      // Highlighted Brand Logo
                      const GtecELessonsLogo(
                        height: 76,
                        lightMode: true,
                        showTagline: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
