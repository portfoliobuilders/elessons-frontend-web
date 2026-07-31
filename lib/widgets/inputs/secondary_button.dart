import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_dimensions.dart';

/// Outlined navy button (e.g. "Create new account").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = AppDimensions.socialButtonHeight,
    this.color = AppColors.navy,
    this.preLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color color;
  final String? preLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: color, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            if (preLabel != null) ...[
              Text(preLabel!, style: AppTextStyles.label.copyWith(color: AppColors.slate)),
              const SizedBox(width: 6),
            ],
            Text(label, style: AppTextStyles.heading.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
