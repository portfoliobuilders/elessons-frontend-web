import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Circular progress ring with smooth animation & central percentage indicator.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 54,
    this.strokeWidth = 4.5,
    this.activeColor = AppColors.navy,
    this.trackColor = AppColors.borderSoft,
    this.showText = true,
  });

  final int percent;
  final double size;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final double value = (percent / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: value,
              strokeWidth: strokeWidth,
              activeColor: activeColor,
              trackColor: trackColor,
            ),
          ),
          if (showText)
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.w800,
                color: activeColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.trackColor != trackColor;
}
