import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';

/// A rounded square icon button (search, bell, back, share …) used in headers.
/// Optionally renders a small red badge dot (e.g. unread notifications).
class IconTileButton extends StatelessWidget {
  const IconTileButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.background = AppColors.surfaceAlt,
    this.iconColor = AppColors.navy,
    this.bordered = false,
    this.showDot = false,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color iconColor;
  final bool bordered;
  final bool showDot;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bordered ? Colors.transparent : background,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: bordered ? Border.all(color: AppColors.borderSoft, width: 1.5) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            if (showDot)
              Positioned(
                top: size * 0.22,
                right: size * 0.24,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.signalRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: background, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
