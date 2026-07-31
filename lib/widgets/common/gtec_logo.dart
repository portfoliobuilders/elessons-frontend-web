import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Official G-TEC eLessons.net brand logo from the brand PDF.
///
/// Uses the color mark on light surfaces and the white mark on dark surfaces.
class GtecELessonsLogo extends StatelessWidget {
  const GtecELessonsLogo({
    super.key,
    this.height = 60,
    this.lightMode = false,
    this.showTagline = true,
  });

  final double height;
  /// When true, use the color logo (for light backgrounds).
  /// When false, use the white logo (for dark backgrounds).
  final bool lightMode;
  /// Kept for API compatibility; the official mark already includes brand lockup.
  final bool showTagline;

  static const String _colorAsset =
      'assets/images/brand/elessons-logo-color-128h.png';
  static const String _whiteAsset =
      'assets/images/brand/elessons-logo-white-128h.png';

  @override
  Widget build(BuildContext context) {
    // Official wordmark aspect ≈ 3.92:1 (501×128).
    final double width = height * 3.92;
    return Semantics(
      label: 'G-TEC eLessons.net',
      image: true,
      child: Image.asset(
        lightMode ? _colorAsset : _whiteAsset,
        height: height,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
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
