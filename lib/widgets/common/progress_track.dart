import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Thin rounded progress bar used in cards and the curriculum.
/// Animates its fill on first build to mirror the design's micro-interaction.
class ProgressTrack extends StatelessWidget {
  const ProgressTrack({
    super.key,
    required this.value,
    this.height = 6,
    this.trackColor = AppColors.trackBg,
    this.fillColor = AppColors.navy,
    this.animate = true,
  });

  final double value; // 0..1
  final double height;
  final Color trackColor;
  final Color fillColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Container(height: height, color: trackColor),
          if (animate)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                widthFactor: v,
                child: Container(height: height, color: fillColor),
              ),
            )
          else
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(height: height, color: fillColor),
            ),
        ],
      ),
    );
  }
}
