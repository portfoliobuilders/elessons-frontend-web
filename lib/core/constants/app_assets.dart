/// Asset path constants. Populate the referenced files under /assets and
/// register them in pubspec.yaml. The design itself is vector/CSS-driven, so
/// most visuals are reproduced as Flutter widgets; these slots are reserved
/// for raster art (illustrations, photos) and Lottie animations.
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/images';
  static const String _icon = 'assets/icons';
  static const String _lottie = 'assets/lottie';

  // Reserved raster slots (add files as needed).
  static const String logoMark = '$_icon/logo_mark.png';
  static const String onboardingHero = '$_img/onboarding_hero.png';
  static const String emptyCart = '$_img/empty_cart.png';
  static const String emptyLibrary = '$_img/empty_library.png';

  // Lottie slots.
  static const String loading = '$_lottie/loading.json';
  static const String success = '$_lottie/success.json';
}
