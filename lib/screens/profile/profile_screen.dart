import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/app_page_route.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../routes/app_routes.dart';
import '../cart/complete_profile_screen.dart';
import '../cart/order_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'purchase_history_screen.dart';

/// 28 · Profile & Menu.
///
/// Content-only tab body shown inside [HomeShell]. Hosts a nested navigator
/// so that profile sub-screen navigation (Edit Profile, Purchase History, Help,
/// Complete Profile, etc.) occurs smoothly within the content panel without
/// unmounting the parent shell or left sidebar.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<NavigatorState> _profileNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final nav = _profileNavKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        }
      },
      child: Navigator(
        key: _profileNavKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case AppRoutes.editProfile:
              page = const EditProfileScreen();
              break;
            case AppRoutes.purchaseHistory:
              page = const PurchaseHistoryScreen();
              break;
            case AppRoutes.orderDetail:
              page = const OrderDetailScreen();
              break;
            case AppRoutes.completeProfile:
              page = const CompleteProfileScreen();
              break;
            case AppRoutes.help:
              page = const HelpScreen();
              break;
            case '/':
            default:
              page = const _ProfileMainContent();
              break;
          }
          return AppPageRoute.fadeSlide(page, settings: settings);
        },
      ),
    );
  }
}

class _ProfileMainContent extends StatefulWidget {
  const _ProfileMainContent();

  @override
  State<_ProfileMainContent> createState() => _ProfileMainContentState();
}

class _ProfileMainContentState extends State<_ProfileMainContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadStats();
    });
  }

  Future<void> _logOut() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  String _regionLabel(String region, String currency) {
    const countries = {'IN': 'India', 'AE': 'UAE', 'US': 'United States'};
    const symbols = {'INR': '₹', 'AED': 'د.إ', 'USD': '\$'};
    final country = countries[region] ?? region;
    final symbol = symbols[currency] ?? currency;
    return '$country · $symbol';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = context.watch<ProfileProvider>().stats;
    final settings = context.watch<SettingsProvider>();
    final profile = auth.user?.profile;
    final gradeName = profile?.gradeName ?? 'Class 10';
    final board = profile?.board ?? 'CBSE';
    final region = profile?.region ?? 'IN';
    final currency = profile?.currency ?? 'INR';
    final kyc = profile?.kycPercent ?? 0;
    return ColoredBox(
      color: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
        children: <Widget>[
          _ProfileHeaderCard(
            name: auth.displayName,
            email: auth.displayEmail,
            initials: auth.initials,
            subtitle: '$board · $gradeName',
            courses: '${stats.courses}',
            avgProgress: '${stats.avgProgress}%',
            dayStreak: '${stats.dayStreak}',
            onEdit: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          const SizedBox(height: 22),
          // KYC prompt
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.completeProfile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppColors.redBg, Color(0xFFFBEEF0)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF6D7DA), width: 1.5),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.signalRed,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.signalRed.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.how_to_reg_outlined,
                        size: 21, color: Colors.white),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Complete your profile',
                            style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 13.5, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          '$kyc% done · unlock certificates & doubt support',
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFA06A6E)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 19, color: AppColors.signalRed),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Account'),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
              _MenuRow(
                icon: Icons.public_rounded,
                label: 'Region & Currency',
                trailing: _ValueBadge(_regionLabel(region, currency)),
              ),
              _MenuRow(
                icon: Icons.work_outline_rounded,
                label: 'Class & Board',
                trailing: _ValueBadge('$gradeName · $board'),
              ),
              _MenuRow(
                icon: Icons.calendar_today_outlined,
                label: 'Purchase History',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.purchaseHistory),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Preferences & Support'),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                trailing: _PillSwitch(
                  value: settings.notificationsEnabled,
                  onChanged: (bool value) =>
                      settings.setNotificationsEnabled(value),
                ),
              ),
              _MenuRow(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => Navigator.pushNamed(context, AppRoutes.help),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // logout
          GestureDetector(
            onTap: _logOut,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.redBg,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: const Color(0xFFF6D7DA), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.logout_rounded,
                      size: 18, color: AppColors.signalRed),
                  SizedBox(width: 9),
                  Text('Log Out',
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.signalRed)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.subtitle,
    required this.courses,
    required this.avgProgress,
    required this.dayStreak,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String initials;
  final String subtitle;
  final String courses;
  final String avgProgress;
  final String dayStreak;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 18),
            spreadRadius: -16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -30,
              top: -34,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 62,
                      height: 62,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5),
                      ),
                      child: Text(initials,
                          style: AppTextStyles.mono.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: Colors.white)),
                          const SizedBox(height: 3),
                          Text(email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onNavySubtle)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.school_outlined,
                                    size: 13, color: AppColors.onNavyAccent),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    subtitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onNavySubtle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: _ProfileStat(value: courses, label: 'Courses')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _ProfileStat(
                            value: avgProgress, label: 'Avg. progress')),
                    const SizedBox(width: 10),
                    Expanded(
                        child:
                            _ProfileStat(value: dayStreak, label: 'Day streak')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onNavyAccent)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 11),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.muted)),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F7)));
      }
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: rows),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: AppColors.navy),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink)),
            ),
            const SizedBox(width: 10),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Color(0xFFC2C8D2)),
          ],
        ),
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.navy)),
    );
  }
}

class _PillSwitch extends StatelessWidget {
  const _PillSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.navy : const Color(0xFFCBD2DE),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
