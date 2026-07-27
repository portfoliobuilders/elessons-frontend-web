import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import '../common/gtec_logo.dart';
import '../common/hover_builder.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final notifs = context.watch<NotificationProvider>();

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.borderSofter, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // ── Brand Header ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GtecELessonsLogo(height: 54, lightMode: true),
          ),

          const SizedBox(height: 32),

          // ── Navigation Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'NAVIGATION',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Core Navigation Tabs ──
          _SidebarNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: AppStrings.navHome,
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _SidebarNavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: AppStrings.navStore,
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _SidebarNavItem(
            icon: Icons.sensors_rounded,
            activeIcon: Icons.sensors_rounded,
            label: AppStrings.navLive,
            active: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _SidebarNavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: AppStrings.navLearnings,
            active: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _SidebarNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: AppStrings.navProfile,
            active: currentIndex == 4,
            onTap: () => onTap(4),
          ),

          const SizedBox(height: 24),

          // ── Shortcuts Section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'QUICK ACCESS',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _SidebarNavItem(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'Cart',
            badgeCount: cart.quote.lines.length,
            active: currentIndex == 5,
            onTap: () => onTap(5),
          ),
          _SidebarNavItem(
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
            label: 'Notifications',
            badgeCount: notifs.unread,
            active: currentIndex == 6,
            onTap: () => onTap(6),
          ),
          _SidebarNavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: 'Search Courses',
            active: currentIndex == 7,
            onTap: () => onTap(7),
          ),

          const Spacer(),

          // ── User Footer / Profile Summary ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.borderSofter),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.navy,
                  child: Text(
                    auth.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auth.displayName,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.displayEmail.isNotEmpty
                            ? auth.displayEmail
                            : 'CBSE Student',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.signalRed),
                  tooltip: 'Logout',
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (_) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: HoverBuilder(
        onTap: onTap,
        builder: (context, isHovered) {
          final bgColor = active
              ? AppColors.navy
              : (isHovered ? AppColors.surface : Colors.transparent);

          final textColor = active
              ? Colors.white
              : (isHovered ? AppColors.navy : AppColors.ink);

          final iconColor = active
              ? Colors.white
              : (isHovered ? AppColors.navy : AppColors.iconMuted);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Row(
              children: [
                Icon(active ? activeIcon : icon, size: 20, color: iconColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: active ? AppColors.signalRed : AppColors.navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
