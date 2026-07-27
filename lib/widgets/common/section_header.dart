import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

/// "Section title  …  See all" row used throughout home/store/learning.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.titleStyle,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(title, style: titleStyle ?? AppTextStyles.sectionTitle),
        ),
        if (action != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Text(
              action!,
              style: AppTextStyles.buttonSm.copyWith(color: AppColors.navy),
            ),
          ),
      ],
    );
  }
}
