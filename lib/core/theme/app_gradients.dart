import 'package:flutter/material.dart';
import 'colors.dart';

/// G-TEC Design System — Gradient tokens.
/// Translated from the design's `linear-gradient` definitions.
class AppGradients {
  AppGradients._();

  /// Welcome backdrop — `linear-gradient(165deg,#21356B,#16244A 52%,#0A1228)`
  static const LinearGradient welcome = LinearGradient(
    begin: Alignment(0.5, -1),
    end: Alignment(-0.3, 1),
    colors: [AppColors.navyLight, AppColors.navy, AppColors.navyDarkest],
    stops: [0.0, 0.52, 1.0],
  );

  /// Auth hero header — `linear-gradient(155deg,#21356B,#16244A 58%,#0E1A38)`
  static const LinearGradient authHero = LinearGradient(
    begin: Alignment(0.6, -1),
    end: Alignment(-0.4, 1),
    colors: [AppColors.navyLight, AppColors.navy, AppColors.navyDeep],
    stops: [0.0, 0.58, 1.0],
  );

  /// Continue-learning / live cards — `linear-gradient(140deg,#21356B,#16244A 55%,#0E1A38)`
  static const LinearGradient heroCard = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: [AppColors.navyLight, AppColors.navy, AppColors.navyDeep],
    stops: [0.0, 0.55, 1.0],
  );

  /// Compact live banner — `linear-gradient(135deg,#21356B,#16244A 60%,#0E1A38)`
  static const LinearGradient liveBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navyLight, AppColors.navy, AppColors.navyDeep],
    stops: [0.0, 0.6, 1.0],
  );

  /// Skeleton / placeholder hatch fill (used for image stand-ins).
  static const LinearGradient skeleton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6EBF4), Color(0xFFEEF2F8)],
  );
}
