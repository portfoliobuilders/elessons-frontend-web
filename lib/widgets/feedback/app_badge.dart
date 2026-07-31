import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Small status badge / count pill.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color = AppColors.navy,
    this.foreground = Colors.white,
    this.dense = false,
  });

  final String label;
  final Color color;
  final Color foreground;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 7 : 9, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: dense ? 9 : 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: foreground,
        ),
      ),
    );
  }
}
