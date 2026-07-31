import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/assessment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/doubt_provider.dart';
import 'providers/home_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/live_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/razorpay_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/assessment_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/doubt_repository.dart';
import 'repositories/learning_repository.dart';
import 'repositories/live_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/progress_repository.dart';
import 'repositories/search_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/video_repository.dart';
import 'routes/app_router.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'routes/app_routes.dart';

/// Global navigator key — lets non-widget layers (e.g. a forced logout on an
/// unrecoverable 401) drive navigation.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  debugPrint("ACTIVE BASE URL: ${AppConfig.baseUrl}");
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Persistence must be ready before any provider reads the session.
  await LocalStorageService.instance.init();

  debugPrint('==================================================');
  debugPrint('🚀 [AppConfig] Active Base URL: ${AppConfig.baseUrl}');
  debugPrint(
      '📱 [AppConfig] Platform: TargetPlatform.${defaultTargetPlatform.name}, kIsWeb: $kIsWeb');
  debugPrint('==================================================');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const GtecApp());
}

/// Root application widget for the G-TEC tuition platform.
class GtecApp extends StatelessWidget {
  const GtecApp({super.key});

  @override
  Widget build(BuildContext context) {
    // One shared HTTP client; repositories are thin and constructed once.
    final api = ApiClient.instance;
    final authRepo = AuthRepository(api);
    final userRepo = UserRepository(api);
    final catalogRepo = CatalogRepository(api);
    final cartRepo = CartRepository(api);
    final paymentRepo = PaymentRepository(api);
    final progressRepo = ProgressRepository(api);
    final assessmentRepo = AssessmentRepository(api);
    final notificationRepo = NotificationRepository(api);
    final searchRepo = SearchRepository(api);
    final liveRepo = LiveRepository(api);
    final doubtRepo = DoubtRepository(api);
    final videoRepo = VideoRepository(api); // used by VideoPlayer screen
    final learningRepo = LearningRepository(api);

    // Auth is constructed eagerly so we can wire forced-logout navigation.
    final authProvider = AuthProvider(
      authRepository: authRepo,
      userRepository: userRepo,
    )..onForcedLogout = () {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      };

    return MultiProvider(
      providers: [
        // Expose the video repo for the player screen (read via context.read).
        Provider<VideoRepository>.value(value: videoRepo),

        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LearningProvider>(
          create: (_) => LearningProvider(learningRepo),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<CatalogProvider>(
          create: (_) => CatalogProvider(catalogRepo),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(
            catalogRepository: catalogRepo,
            progressRepository: progressRepo,
          ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(cartRepo),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(
            paymentRepository: paymentRepo,
            userRepository: userRepo,
          ),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(progressRepo),
        ),
        ChangeNotifierProvider<AssessmentProvider>(
          create: (_) => AssessmentProvider(assessmentRepo),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(notificationRepo),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(searchRepo),
        ),
        ChangeNotifierProvider<LiveProvider>(
          create: (_) => LiveProvider(liveRepo),
        ),
        ChangeNotifierProvider<DoubtProvider>(
          create: (_) => DoubtProvider(doubtRepo),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            userRepository: userRepo,
            progressRepository: progressRepo,
          ),
        ),
        ChangeNotifierProvider<RazorpayProvider>(
          create: (_) => RazorpayProvider()..init(),
        ),
      ],
      child: MaterialApp(
        title: 'G-TEC Education',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          final clamped = mq.textScaler.clamp(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.15,
          );
          return MediaQuery(
            data: mq.copyWith(textScaler: clamped),
            child: ScrollConfiguration(
              behavior: const _GtecScrollBehavior(),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

/// Bouncing scroll physics everywhere (iOS-style), with a thin scrollbar on
/// large screens, matching the smooth feel of the source prototype.
class _GtecScrollBehavior extends ScrollBehavior {
  const _GtecScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
