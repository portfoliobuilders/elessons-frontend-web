import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_dimensions.dart';

/// Outlined third-party auth button (Google / Apple) with a custom glyph.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.glyph,
    this.onTap,
  });

  final String label;
  final Widget glyph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.socialButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl + 1),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 18, height: 18, child: glyph),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.buttonSm.copyWith(fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

/// Google "G" multicolour mark drawn with a CustomPainter (no asset needed).
class GoogleGlyph extends StatelessWidget {
  const GoogleGlyph({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final p = Paint()..style = PaintingStyle.fill;
    // Simplified four-arc "G" approximation faithful to the mark's colours.
    p.color = AppColors.googleBlue;
    canvas.drawArc(Rect.fromLTWH(0, 0, s, s), -0.5, 1.3, true, p..color = AppColors.googleBlue);
    canvas.drawArc(Rect.fromLTWH(0, 0, s, s), 0.8, 1.5, true, p..color = AppColors.googleGreen);
    canvas.drawArc(Rect.fromLTWH(0, 0, s, s), 2.3, 1.5, true, p..color = AppColors.googleYellow);
    canvas.drawArc(Rect.fromLTWH(0, 0, s, s), 3.8, 1.5, true, p..color = AppColors.googleRed);
    // Punch out centre + right notch.
    final hole = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.28, hole);
    canvas.drawRect(Rect.fromLTWH(s * 0.5, s * 0.38, s * 0.5, s * 0.24), hole);
    canvas.drawRect(Rect.fromLTWH(s * 0.52, s * 0.42, s * 0.34, s * 0.16),
        Paint()..color = AppColors.googleBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Apple mark glyph.
class AppleGlyph extends StatelessWidget {
  const AppleGlyph({super.key});
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.apple, size: 20, color: AppColors.ink);
}
