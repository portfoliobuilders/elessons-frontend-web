import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Official G-TEC eLessons.net Brand Logo & Lockup Widget (Prominent, High Visibility).
///
/// Matches the exact official brand identity:
///   G-TEC
/// eLessons.net
/// Your Virtual Classroom
class GtecELessonsLogo extends StatelessWidget {
  const GtecELessonsLogo({
    super.key,
    this.height = 60,
    this.lightMode = false,
    this.showTagline = true,
  });

  final double height;
  final bool lightMode;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = height * 0.52;
    final Color gtecColor = lightMode ? const Color(0xFF163E75) : const Color(0xFF60A5FA);
    final Color cyanColor = const Color(0xFF0096C7);
    final Color mainTextColor = lightMode ? const Color(0xFF111111) : Colors.white;
    final Color taglineColor = lightMode ? const Color(0xFF555555) : const Color(0xFFCBD5E1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Cyan 'e'
            Text(
              'e',
              style: TextStyle(
                fontSize: baseFontSize * 1.35,
                fontWeight: FontWeight.bold,
                color: cyanColor,
                fontFamily: 'serif',
                height: 1.0,
              ),
            ),
            const SizedBox(width: 1),

            // Top G-TEC and main Lessons.net stack
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'G-TEC',
                  style: TextStyle(
                    fontSize: baseFontSize * 0.42,
                    fontWeight: FontWeight.w900,
                    color: gtecColor,
                    letterSpacing: 0.8,
                    height: 1.0,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Lessons',
                    style: TextStyle(
                      fontSize: baseFontSize * 1.1,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                      letterSpacing: -0.4,
                      fontFamily: 'serif',
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(
                        text: '.net',
                        style: TextStyle(
                          fontSize: baseFontSize * 1.05,
                          fontWeight: FontWeight.bold,
                          color: cyanColor,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 3),
          Padding(
            padding: EdgeInsets.only(left: baseFontSize * 0.3),
            child: Text(
              'Your Virtual Classroom',
              style: TextStyle(
                fontSize: baseFontSize * 0.38,
                fontWeight: FontWeight.w600,
                color: taglineColor,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Backwards-compatible logo mark widget with enlarged scaling.
class GtecLogoMark extends StatelessWidget {
  const GtecLogoMark({
    super.key,
    this.size = 40,
    this.tileColor = AppColors.white,
    this.insetColor = AppColors.signalRed,
  });

  final double size;
  final Color tileColor;
  final Color insetColor;

  @override
  Widget build(BuildContext context) {
    return GtecELessonsLogo(
      height: size * 1.35,
      lightMode: tileColor == AppColors.white,
      showTagline: false,
    );
  }
}

/// Backwards-compatible wordmark lockup widget with enlarged scaling.
class GtecWordmark extends StatelessWidget {
  const GtecWordmark({
    super.key,
    this.markSize = 40,
    this.fontSize = 18,
    this.color = AppColors.white,
    this.trailing,
    this.accentColor = AppColors.onNavyAccent,
  });

  final double markSize;
  final double fontSize;
  final Color color;
  final String? trailing;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GtecELessonsLogo(
      height: markSize * 1.5,
      lightMode: color == AppColors.navy || color == AppColors.ink,
      showTagline: true,
    );
  }
}
