import 'package:flutter/material.dart';

/// Translucent circles overlaid on navy gradient surfaces (purely decorative,
/// matching the soft "orbs" in the design's hero backgrounds).
class DecorBlob extends StatelessWidget {
  const DecorBlob({
    super.key,
    required this.size,
    this.opacity = 0.05,
    this.color = Colors.white,
  });

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
