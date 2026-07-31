import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/live_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../cart/cart_screen.dart';
import '../common/notifications_screen.dart';
import '../common/search_screen.dart';
import '../learning/live_classes_screen.dart';
import '../learning/my_learnings_screen.dart';
import '../profile/profile_screen.dart';
import '../store/store_screen.dart';
import 'home_screen.dart';

import '../../core/utils/responsive.dart';
import '../../widgets/navigation/desktop_sidebar.dart';

/// Hosts the primary tabs (Home · Store · Live · Learnings · Profile · Cart · Notifications · Search) behind the
/// desktop sidebar or custom bottom navigation. Tabs are kept alive via an [IndexedStack].
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  late int _index = widget.initialIndex;

  late final List<Widget> _tabs = const [
    HomeTab(),
    StoreScreen(),
    LiveClassesScreen(),
    MyLearningsScreen(),
    ProfileScreen(),
    CartScreen(),
    NotificationsScreen(),
    SearchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentTab(_index);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 [HomeShell] App resumed to foreground — auto-refreshing active providers...');
      _refreshAllProviders();
    }
  }

  void _onTabSelected(int i) {
    setState(() => _index = i);
    _refreshCurrentTab(i);
  }

  void _refreshCurrentTab(int i) {
    final auth = context.read<AuthProvider>();
    final gradeId = auth.user?.profile?.gradeId;
    if (i == 0 || i == 1) {
      // Home & Store share HomeProvider + CatalogProvider
      context.read<CatalogProvider>().clearCache();
      context.read<HomeProvider>().refresh(gradeId: gradeId);
      context.read<LiveProvider>().loadUpcoming();
    } else if (i == 2) {
      // Live Sessions tab
      context.read<LiveProvider>().loadUpcoming();
    } else if (i == 3) {
      // My Learnings tab
      context.read<LearningProvider>().loadLearnings(force: true);
    } else if (i == 5) {
      // Cart tab
      final currency = auth.user?.profile?.currency;
      context.read<CartProvider>().load(currency: currency);
    } else if (i == 6) {
      // Notifications tab
      context.read<NotificationProvider>().load();
    }
  }

  void _refreshAllProviders() {
    final gradeId = context.read<AuthProvider>().user?.profile?.gradeId;
    context.read<CatalogProvider>().clearCache();
    context.read<HomeProvider>().refresh(gradeId: gradeId);
    context.read<LiveProvider>().loadUpcoming();
    context.read<LearningProvider>().loadLearnings(force: true);
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Row(
          children: [
            DesktopSidebar(
              currentIndex: _index,
              onTap: _onTabSelected,
            ),
            Expanded(
              child: IndexedStack(index: _index, children: _tabs),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: GtecBottomNav(
        currentIndex: _index,
        onTap: _onTabSelected,
      ),
      body: IndexedStack(index: _index, children: _tabs),
    );
  }
}
