import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import 'icon_tile_button.dart';

/// Back button + two-segment step progress + "n/total" label, shared by the
/// onboarding flow (screens 07–08).
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.step,
    this.total = 2,
    this.onBack,
  });

  final int step; // 1-based
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 6, 26, 0),
      child: Row(
        children: [
          IconTileButton(
            icon: Icons.chevron_left,
            iconSize: 24,
            bordered: true,
            background: Colors.white,
            iconColor: AppColors.ink,
            size: 42,
            onTap: onBack ?? () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < total; i++) ...[
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: i < step
                            ? AppColors.navy
                            : const Color(0xFFE7EAF0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  if (i != total - 1) const SizedBox(width: 7),
                ],
              ],
            ),
          ),
          const SizedBox(width: 13),
          Text(
            '$step/$total',
            style: AppTextStyles.label.copyWith(
              fontSize: 12.5,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
