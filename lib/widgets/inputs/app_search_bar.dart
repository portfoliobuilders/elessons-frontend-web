import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';

/// Search field used in the store/search headers. Read-only mode lets it act
/// as a tappable entry point that navigates to the Search screen.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.hint = 'Search…',
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.trailingFilter = false,
    this.onFilter,
  });

  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final bool trailingFilter;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderSoft, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 19, color: AppColors.muted),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    onTap: onTap,
                    onChanged: onChanged,
                    cursorColor: AppColors.navy,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: AppTextStyles.heading.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (trailingFilter) ...[
          const SizedBox(width: 11),
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.tune, size: 20, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}
