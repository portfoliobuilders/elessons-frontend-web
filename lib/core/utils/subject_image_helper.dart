import 'package:flutter/material.dart';
import 'hatch_painter.dart';

/// Helper utility for resolving and rendering subject banner/thumbnail images.
class SubjectImageHelper {
  SubjectImageHelper._();

  /// Resolves the asset image path based on subject name or code.
  static String? getBannerAsset(String? name, [String? code]) {
    final n = (name ?? '').toLowerCase();
    final c = (code ?? '').toLowerCase();

    if (n.contains('science') || c.contains('sci')) {
      return 'assets/images/science_banner.jpg';
    }
    if (n.contains('math') || c.contains('mat')) {
      return 'assets/images/maths_banner.jpg';
    }
    if (n.contains('english') || c.contains('eng')) {
      return 'assets/images/english_banner.jpg';
    }
    if (n.contains('history') || c.contains('his')) {
      return 'assets/images/history_course_trailer.png';
    }
    if (n.contains('geography') || c.contains('geo')) {
      return 'assets/images/geography_course_trailer.png';
    }
    return null;
  }

  /// Builds a subject thumbnail image with graceful fallback to [HatchTile].
  static Widget buildSubjectThumbnail({
    required String name,
    String? code,
    required double width,
    required double height,
    double radius = 14,
    BoxFit fit = BoxFit.cover,
  }) {
    final asset = getBannerAsset(name, code);
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          asset,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => HatchTile(
            width: width,
            height: height,
            radius: radius,
            label: code ?? (name.isNotEmpty ? name.substring(0, 1) : '?'),
          ),
        ),
      );
    }
    return HatchTile(
      width: width,
      height: height,
      radius: radius,
      label: code ?? (name.isNotEmpty ? name.substring(0, 1) : '?'),
    );
  }
}
