import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'decorative_blobs.dart';

/// A navy gradient surface with soft decorative orbs — the recurring hero
/// container (welcome backdrop, continue-learning card, live banner).
class GradientHero extends StatelessWidget {
  const GradientHero({
    super.key,
    required this.child,
    this.gradient = AppGradients.heroCard,
    this.borderRadius,
    this.padding,
    this.blobs = const [
      HeroBlob(size: 140, top: -30, right: -30, opacity: 0.05),
    ],
    this.height,
    this.boxShadow,
  });

  final Widget child;
  final Gradient gradient;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final List<HeroBlob> blobs;
  final double? height;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          for (final b in blobs)
            Positioned(
              top: b.top,
              bottom: b.bottom,
              left: b.left,
              right: b.right,
              child: DecorBlob(size: b.size, opacity: b.opacity),
            ),
          child,
        ],
      ),
    );
  }
}

class HeroBlob {
  const HeroBlob({
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.opacity = 0.05,
  });
  final double size;
  final double? top, bottom, left, right;
  final double opacity;
}
