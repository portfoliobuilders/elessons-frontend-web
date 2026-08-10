/// Named-route registry for the entire G-TEC app (38 mobile screens).
/// Screens are added to [AppRouter] as they are implemented.
class AppRoutes {
  AppRoutes._();

  // ── Get started (1–6) ──
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ── Personalize (7–8) ──
  static const String onboardBoard = '/onboarding/board';
  static const String onboardClass = '/onboarding/class';

  // ── Core shell + tabs (9–13, 26, 28) ──
  static const String home = '/home'; // bottom-nav shell
  static const String homeFirstTime = '/home/first-time';
  static const String notifications = '/notifications';
  static const String search = '/search';

  // ── Discover & purchase (13–19) ──
  static const String store = '/store';
  static const String courseDetail = '/course/detail';
  
  // ── Subject Details ──
  static const String subjectDetail = '/subject/detail';
  static const String subjectModules = '/subject/modules';
  static const String subjectLessons = '/subject/lessons';
  static const String subjectLessonDetail = '/subject/lesson-detail';
  static const String subjectQuiz = '/subject/quiz';
  static const String subjectAssignment = '/subject/assignment';
  static const String subjectProgress = '/subject/progress';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmed = '/order/confirmed';
  static const String completeProfile = '/profile/complete-kyc';

  // ── Learn (20–25, 27) ──
  static const String curriculum = '/course/curriculum';
  static const String videoPlayer = '/learn/video';
  static const String pdfViewer = '/learn/notes';
  static const String askDoubt = '/learn/ask-doubt';
  static const String liveClasses = '/live/schedule';
  static const String liveRoom = '/live/room';
  static const String downloads = '/learn/downloads';

  // ── Account & support (29–34) ──
  static const String editProfile = '/profile/edit';
  static const String purchaseHistory = '/profile/purchases';
  static const String orderDetail = '/order/detail';
  static const String help = '/help';
  static const String emptyCart = '/cart/empty';
  static const String emptyLibrary = '/learnings/empty';

  // ── Assessment (35–38) ──
  static const String assignments = '/assignments';
  static const String testAttempt = '/test/attempt';
  static const String testResult = '/test/result';
  static const String progress = '/progress';
}
