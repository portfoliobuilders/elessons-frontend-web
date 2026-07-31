import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Reproduces the design's `repeating-linear-gradient(135deg, …)` hatch used
/// as a placeholder for imagery / thumbnails. Pixel-faithful to the mockup,
/// and a clean stand-in until real assets are wired in via [AppAssets].
class HatchPainter extends CustomPainter {
  const HatchPainter({
    this.colorA = const Color(0xFFE6EBF4),
    this.colorB = const Color(0xFFEEF2F8),
    this.band = 9,
  });

  final Color colorA;
  final Color colorB;
  final double band;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colorA);
    final stripe = Paint()..color = colorB;
    final double step = band * 2;
    final double diag = size.width + size.height;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (double x = -size.height; x < diag; x += step) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + band, 0)
        ..lineTo(x + band + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, stripe);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HatchPainter old) =>
      old.colorA != colorA || old.colorB != colorB || old.band != band;
}

/// Convenience widget: a hatched placeholder tile with an optional centered
/// monogram (e.g. subject code "SST"), matching the design's thumbnails.
class HatchTile extends StatelessWidget {
  const HatchTile({
    super.key,
    this.height,
    this.width,
    this.radius = 13,
    this.label,
    this.band = 9,
    this.child,
  });

  final double? height;
  final double? width;
  final double radius;
  final String? label;
  final double band;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: HatchPainter(band: band),
        child: SizedBox(
          height: height,
          width: width,
          child: Center(
            child: child ??
                (label == null
                    ? null
                    : Text(
                        label!,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: AppColors.monoText,
                        ),
                      )),
          ),
        ),
      ),
    );
  }
}
