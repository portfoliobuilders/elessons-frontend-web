import 'package:flutter/material.dart';

import '../core/utils/app_page_route.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';

// Auth & onboarding
import '../screens/landingscreen/landingscreen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/create_account_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/onboarding/onboarding_board_screen.dart';
import '../screens/onboarding/onboarding_class_screen.dart';

// Shell, tabs & discovery
import '../screens/home/home_shell.dart';
import '../screens/home/home_first_time_screen.dart';
import '../screens/store/course_detail_screen.dart';
import '../screens/course/by_module_screen.dart';

// Subject & Lessons
import '../screens/learning/subject_dashboard_screen.dart';
import '../screens/modules/modules_screen.dart';
import '../screens/lessons/lessons_screen.dart';
import '../screens/lessons/lesson_detail_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/assignment/assignment_screen.dart';
import '../screens/subject/subject_progress_screen.dart';

// Cart & purchase
import '../screens/cart/checkout_screen.dart';
import '../screens/cart/order_confirmed_screen.dart';
import '../screens/cart/complete_profile_screen.dart';
import '../screens/cart/empty_cart_screen.dart';
import '../screens/cart/order_detail_screen.dart';

// Learn & live
import '../screens/course/curriculum_screen.dart';
import '../screens/course/video_player_screen.dart';
import '../screens/course/pdf_viewer_screen.dart';
import '../screens/course/ask_doubt_screen.dart';
import '../screens/learning/live_room_screen.dart';
import '../screens/learning/downloads_screen.dart';
import '../screens/learning/empty_library_screen.dart';

// Account & support
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/purchase_history_screen.dart';
import '../screens/profile/help_screen.dart';

// Assessment
import '../screens/assessment/assignments_screen.dart';
import '../screens/assessment/test_attempt_screen.dart';
import '../screens/assessment/test_result_screen.dart';
import '../screens/assessment/progress_screen.dart';

/// Central [onGenerateRoute] for the app. Every named route in [AppRoutes]
/// resolves here to a screen, wrapped in the shared fade/slide transition.
/// The bottom-nav destinations (`home`, `store`) resolve to [HomeShell] with
/// the matching tab pre-selected.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String rawName = settings.name ?? '';
    final Uri uri = Uri.parse(rawName);
    final String pathName = uri.path.isEmpty ? AppRoutes.splash : uri.path;

    // Merge settings arguments with URL query parameters for Web deep links & browser refresh
    Object? finalArguments = settings.arguments;
    if (finalArguments == null && uri.queryParameters.isNotEmpty) {
      finalArguments = Map<String, dynamic>.from(uri.queryParameters);
    }

    final RouteSettings effectiveSettings = RouteSettings(
      name: pathName,
      arguments: finalArguments,
    );

    final Widget page = _pageFor(pathName);

    // Root / tab swaps use a pure fade; forward navigation uses fade + slide.
    final bool isRoot = pathName == AppRoutes.splash ||
        pathName == AppRoutes.welcome ||
        pathName == AppRoutes.home ||
        pathName == AppRoutes.store;

    return isRoot
        ? AppPageRoute.fade(page, settings: effectiveSettings)
        : AppPageRoute.fadeSlide(page, settings: effectiveSettings);
  }

  static Widget _pageFor(String? name) {
    switch (name) {
      // Get started
      case AppRoutes.splash:
        return const SplashScreen();
      case AppRoutes.welcome:
      case AppRoutes.landing:
        return const LandingScreen();
      case AppRoutes.login:
        return const LoginScreen();
      case AppRoutes.createAccount:
        return const CreateAccountScreen();
      case AppRoutes.otp:
        return const OtpScreen();
      case AppRoutes.forgotPassword:
        return const ForgotPasswordScreen();
      case AppRoutes.resetPassword:
        return const ResetPasswordScreen();

      // Personalize
      case AppRoutes.onboardBoard:
        return const OnboardingBoardScreen();
      case AppRoutes.onboardClass:
        return const OnboardingClassScreen();

      // Shell + tabs
      case AppRoutes.home:
        return const HomeShell(initialIndex: 0);
      case AppRoutes.store:
        return const HomeShell(initialIndex: 1);
      case AppRoutes.homeFirstTime:
        return const HomeFirstTimeScreen();
      case AppRoutes.notifications:
        return const HomeShell(initialIndex: 6);
      case AppRoutes.search:
        return const HomeShell(initialIndex: 7);

      // Discover & purchase
      case AppRoutes.courseDetail:
        return const CourseDetailScreen();
      case AppRoutes.byModule:
        return const ByModuleScreen();

      // Subject & Lessons
      case AppRoutes.subjectDetail:
        return const SubjectDashboardScreen();
      case AppRoutes.subjectModules:
        return const ModulesScreen();
      case AppRoutes.subjectLessons:
        return const LessonsScreen();
      case AppRoutes.subjectLessonDetail:
        return const LessonDetailScreen();
      case AppRoutes.subjectQuiz:
        return const QuizScreen();
      case AppRoutes.subjectAssignment:
        return const AssignmentScreen();
      case AppRoutes.subjectProgress:
        return const SubjectProgressScreen();

      case AppRoutes.cart:
        return const HomeShell(initialIndex: 5);
      case AppRoutes.checkout:
        return const CheckoutScreen();
      case AppRoutes.orderConfirmed:
        return const OrderConfirmedScreen();
      case AppRoutes.completeProfile:
        return const CompleteProfileScreen();

      // Learn
      case AppRoutes.curriculum:
        return const CurriculumScreen();
      case AppRoutes.videoPlayer:
        return const VideoPlayerScreen();
      case AppRoutes.pdfViewer:
        return const PdfViewerScreen();
      case AppRoutes.askDoubt:
        return const AskDoubtScreen();
      case AppRoutes.liveClasses:
        return const HomeShell(initialIndex: 2);
      case AppRoutes.liveRoom:
        return const LiveRoomScreen();
      case AppRoutes.downloads:
        return const DownloadsScreen();

      // Account & support
      case AppRoutes.editProfile:
        return const EditProfileScreen();
      case AppRoutes.purchaseHistory:
        return const PurchaseHistoryScreen();
      case AppRoutes.orderDetail:
        return const OrderDetailScreen();
      case AppRoutes.help:
        return const HelpScreen();
      case AppRoutes.emptyCart:
        return const EmptyCartScreen();
      case AppRoutes.emptyLibrary:
        return const EmptyLibraryScreen();

      // Assessment
      case AppRoutes.assignments:
        return const AssignmentsScreen();
      case AppRoutes.testAttempt:
        return const TestAttemptScreen();
      case AppRoutes.testResult:
        return const TestResultScreen();
      case AppRoutes.progress:
        return const ProgressScreen();

      // Fallback
      default:
        return const LandingScreen();
    }
  }
}
