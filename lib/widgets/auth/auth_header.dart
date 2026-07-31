import 'package:flutter/material.dart';

/// Authentication Screen Title & Subtitle Header Widget.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleFontSize,
  });

  final String title;
  final String subtitle;
  final double? titleFontSize;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize ?? (isMobile ? 28 : 40),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF222222),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF777777),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
