import 'package:flutter/material.dart';
import '../common/gtec_logo.dart';

/// Senior UI Architect Level SaaS / EdTech Authentication Layout.
///
/// Desktop (>1200px): Left 45% 3D Animated Hero & Feature Panel, Right 55% Centered Auth Card.
/// Tablet (768–1199px): Left 40% 3D Animated Hero & Feature Panel, Right 60% Centered Auth Card.
/// Mobile (<768px): Hide Left Panel, display Centered Auth Card.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.childCard,
    this.lottiePath = 'assets/lottie/login.json',
  });

  final Widget childCard;
  final String lottiePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1200;
          final isTablet = width >= 768 && width < 1200;

          if (isDesktop || isTablet) {
            final double leftFlex = isDesktop ? 45 : 40;
            final double rightFlex = isDesktop ? 55 : 60;

            return Row(
              children: [
                // ── Left Branding & 3D EdTech Animated Panel (45% / 40%) ──
                Expanded(
                  flex: leftFlex.toInt(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0B132B),
                          Color(0xFF1C2541),
                          Color(0xFF0F172A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Logo & Lockup
                        const GtecWordmark(
                          markSize: 46,
                          fontSize: 24,
                          trailing: 'EDUCATION',
                          color: Colors.white,
                          accentColor: Color(0xFFE63946),
                        ),
                        const Spacer(),

                        // Center 3D Vector Dashboard & Student Hero Graphic
                        Center(
                          child: _SeniorEdTechHeroGraphic(
                            width: isDesktop ? 460 : 360,
                            height: isDesktop ? 340 : 280,
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // ── Right Authentication Card Panel (55% / 60%) ──
                Expanded(
                  flex: rightFlex.toInt(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF8FAFC),
                          Color(0xFFEEF5FF),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          vertical: 36,
                          horizontal: isDesktop ? 36 : 20,
                        ),
                        child: childCard,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // ── Mobile Layout (<768px): Hide Left Panel, Centered Auth Card ──
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFEEF5FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: childCard,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Ultra-Premium Pure Flutter 3D EdTech Animated Dashboard & Student Hero Graphic.
class _SeniorEdTechHeroGraphic extends StatefulWidget {
  const _SeniorEdTechHeroGraphic({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<_SeniorEdTechHeroGraphic> createState() =>
      _SeniorEdTechHeroGraphicState();
}

class _SeniorEdTechHeroGraphicState extends State<_SeniorEdTechHeroGraphic>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Ambient Neon Pulse Ring ──
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: widget.width * 0.85,
                  height: widget.height * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE63946).withValues(alpha: 0.3),
                        const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Central Interactive 3D Smart Classroom Card ──
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: Container(
                  width: widget.width * 0.82,
                  height: widget.height * 0.82,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE63946).withValues(alpha: 0.25),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Window Controls Bar
                      Row(
                        children: [
                          _dot(const Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          _dot(const Color(0xFFF59E0B)),
                          const SizedBox(width: 6),
                          _dot(const Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 18,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'gtec.education/live-class',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Active Video Player Illustration
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: widget.height * 0.38,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0F172A),
                                  Color(0xFF16244A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE63946),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE63946).withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Video Info & Waveform Status
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF38BDF8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chapter 4: Quadratic Equations',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Class 10 CBSE · Mathematics',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Floating Glass Badge Top-Left: LIVE Class ──
          Positioned(
            top: 0,
            left: 0,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnim.value * 0.7),
                  child: const _GlassBadge(
                    icon: Icons.circle,
                    iconColor: Color(0xFFE63946),
                    label: 'LIVE Classes',
                  ),
                );
              },
            ),
          ),

          // ── Floating Glass Badge Top-Right: Class 8-12 CBSE ──
          Positioned(
            top: 10,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnim.value * 0.8),
                  child: const _GlassBadge(
                    icon: Icons.menu_book_rounded,
                    iconColor: Color(0xFF38BDF8),
                    label: 'Class 8–12 CBSE',
                  ),
                );
              },
            ),
          ),

          // ── Floating Glass Badge Bottom-Right: 99.4% Pass Rate ──
          Positioned(
            bottom: 0,
            right: 5,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnim.value * 0.6),
                  child: const _GlassBadge(
                    icon: Icons.star_rounded,
                    iconColor: Color(0xFFFFC107),
                    label: '99.4% Pass Rate',
                  ),
                );
              },
            ),
          ),

          // ── Floating Glass Badge Bottom-Left: Doubt Solver ──
          Positioned(
            bottom: 5,
            left: 5,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnim.value * 0.5),
                  child: const _GlassBadge(
                    icon: Icons.bolt_rounded,
                    iconColor: Color(0xFFF59E0B),
                    label: 'Instant Doubt Solver',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
