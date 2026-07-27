import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

class NavDestination {
  const NavDestination(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Custom bottom navigation matching the design exactly: the active tab is a
/// navy pill (icon + label, horizontal); inactive tabs are a muted vertical
/// icon + caption.
class GtecBottomNav extends StatelessWidget {
  const GtecBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<NavDestination> destinations = [
    NavDestination(Icons.home_outlined, AppStrings.navHome),
    NavDestination(Icons.grid_view_rounded, AppStrings.navStore),
    NavDestination(Icons.sensors_rounded, AppStrings.navLive),
    NavDestination(Icons.menu_book_outlined, AppStrings.navLearnings),
    NavDestination(Icons.person_outline, AppStrings.navProfile),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      height: AppDimensions.bottomNavHeight + bottomInset,
      padding: EdgeInsets.only(left: 14, right: 14, bottom: 14 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderSofter)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < destinations.length; i++)
            _NavItem(
              destination: destinations[i],
              active: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final NavDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: active
            ? Container(
                key: const ValueKey('active'),
                height: AppDimensions.navPillHeight,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  children: [
                    Icon(destination.icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(destination.label, style: AppTextStyles.navActive),
                  ],
                ),
              )
            : Column(
                key: const ValueKey('inactive'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(destination.icon, size: 22, color: AppColors.iconMuted),
                  const SizedBox(height: 4),
                  Text(destination.label, style: AppTextStyles.navInactive),
                ],
              ),
      ),
    );
  }
}
