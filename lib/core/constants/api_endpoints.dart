/// Every backend route, mapped 1:1 from the NestJS controllers.
///
/// Paths are relative to [AppConfig.baseUrl] (which already includes `/api`).
/// Grouped by module for readability.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth (auth.controller.ts) ──────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resendVerification = '/auth/resend-verification';
  static const String verifyEmail = '/auth/verify-email';
  static const String google = '/auth/google';
  static const String apple = '/auth/apple';
  static const String devLogin = '/auth/dev-login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── Regions (regions.controller.ts) ────────────────────────────────
  static const String regions = '/regions';
  static const String regionsConvert = '/regions/convert';

  // ── Current user (users.controller.ts → @Controller('me')) ─────────
  static const String me = '/me';
  static const String myOrders = '/me/orders';
  static const String checkoutDetails = '/me/checkout-details';
  static const String updateProfile = '/me/profile';
  static const String onboarding = '/me/onboarding';
  static const String updateRegion = '/me/region';
  static const String uploadAvatar = '/me/avatar';
  static const String uploadKycPhoto = '/me/kyc-photo';

  // ── Catalog (catalog.controller.ts) ────────────────────────────────
  static const String grades = '/grades';
  static String grade(String id) => '/grades/$id';
  static String subject(String id) => '/subjects/$id';
  static String chapter(String id) => '/chapters/$id';
  static String lesson(String id) => '/lessons/$id';

  // ── Cart (cart.controller.ts) ──────────────────────────────────────
  static const String cart = '/cart';
  static const String cartQuote = '/cart/quote';
  static const String cartItems = '/cart/items';
  static String cartItem(String productId) => '/cart/items/$productId';

  // ── Payments (payments.controller.ts) ──────────────────────────────
  static const String checkout = '/checkout';
  static const String razorpayVerify = '/razorpay/verify';
  static const String razorpaySubjectOrder = '/razorpay/subject-order';
  static const String webhooksStripe = '/webhooks/stripe';

  // ── Progress (progress.controller.ts) ──────────────────────────────
  static String lessonProgress(String lessonId) => '/lessons/$lessonId/progress';
  static const String myLearnings = '/me/learnings';
  static const String continueLearning = '/me/continue';
  static const String myStats = '/me/stats';

  // ── Video (video.controller.ts) ────────────────────────────────────
  static String playback(String lessonId) => '/lessons/$lessonId/playback';
  static String adminVideoUpload(String id) => '/admin/lessons/$id/video';

  // ── Search (search.controller.ts) ──────────────────────────────────
  static const String search = '/search';

  // ── Notifications (notifications.controller.ts) ────────────────────
  static const String notifications = '/me/notifications';
  static const String notificationsUnreadCount = '/me/notifications/unread-count';
  static String notificationRead(String id) => '/me/notifications/$id/read';
  static const String notificationsReadAll = '/me/notifications/read-all';
  static const String deviceToken = '/me/notifications/device-token';

  // ── Assessments (assessments.controller.ts) ────────────────────────
  static const String assessments = '/assessments';
  static String assessment(String id) => '/assessments/$id';
  static String assessmentSubmit(String id) => '/assessments/$id/submit';
  static const String myAttempts = '/me/attempts';
  
  static const String adminAssessments = '/admin/assessments';
  static String adminAssessment(String id) => '/admin/assessments/$id';
  static String adminAssessmentQuestions(String id) => '/admin/assessments/$id/questions';
  static String adminAssessmentPublish(String id) => '/admin/assessments/$id/publish';

  // ── Doubts (doubts.controller.ts) ──────────────────────────────────
  static const String doubts = '/doubts';
  static const String myDoubts = '/me/doubts';
  static String lessonDoubts(String lessonId) => '/lessons/$lessonId/doubts';
  static String doubtHelpful(String id) => '/doubts/$id/helpful';
  
  static const String teacherDoubts = '/teacher/doubts';
  static String teacherDoubtAnswer(String id) => '/teacher/doubts/$id/answer';

  // ── Live classes (live.controller.ts) ──────────────────────────────
  static const String liveClasses = '/live-classes';
  static String liveReminderOn(String id) => '/live-classes/$id/reminder';
  static String liveReminderOff(String id) => '/live-classes/$id/reminder/off';
  static String liveJoin(String id) => '/live-classes/$id/join';
  static String liveChat(String id) => '/live-classes/$id/chat';
  
  static const String adminLiveClasses = '/admin/live-classes';
  static String adminLiveClassStatus(String id) => '/admin/live-classes/$id/status';

  // ── Admin (admin.controller.ts) ────────────────────────────────────
  static const String adminAnalyticsOverview = '/admin/analytics/overview';
  static const String adminAnalyticsTopCourses = '/admin/analytics/top-courses';
  static const String adminAnalyticsRecentOrders = '/admin/analytics/recent-orders';
  
  static const String adminCurriculum = '/admin/curriculum';
  static const String adminCurriculumReorder = '/admin/curriculum/reorder';
  static const String adminCurriculumPublish = '/admin/curriculum/publish';

  static const String adminGrades = '/admin/grades';
  static String adminGrade(String id) => '/admin/grades/$id';
  
  static const String adminSubjects = '/admin/subjects';
  static String adminSubject(String id) => '/admin/subjects/$id';
  
  static const String adminChapters = '/admin/chapters';
  static String adminChapter(String id) => '/admin/chapters/$id';
  
  static const String adminLessons = '/admin/lessons';
  static String adminLesson(String id) => '/admin/lessons/$id';
  
  static const String adminResources = '/admin/resources';
  static String adminResource(String id) => '/admin/resources/$id';

  static const String adminStudents = '/admin/students';
  static String adminStudent(String id) => '/admin/students/$id';
  static String adminStudentStatus(String id) => '/admin/students/$id/status';
  static String adminStudentRole(String id) => '/admin/students/$id/role';

  static const String adminPricing = '/admin/pricing';
  static const String adminPricingProducts = '/admin/pricing/products';
  static String adminPricingProduct(String id) => '/admin/pricing/products/$id';

  static const String adminOrders = '/admin/orders';
  static String adminOrder(String id) => '/admin/orders/$id';
  static String adminOrderRefund(String id) => '/admin/orders/$id/refund';

  // ── Misc ───────────────────────────────────────────────────────────
  static const String healthCheck = '/'; 
  static const String swaggerDocs = '/docs'; 
  static String uploadAvatarUrl(String file) => '/uploads/avatars/$file';
  static String uploadKycUrl(String file) => '/uploads/kyc/$file';
}
