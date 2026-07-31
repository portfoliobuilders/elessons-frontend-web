/// G-TEC Design System — Component dimension tokens.
class AppDimensions {
  AppDimensions._();

  // Buttons
  static const double buttonHeight = 54; // primary/secondary (screen CTAs)
  static const double buttonHeightCompact = 48; // design-system spec
  static const double socialButtonHeight = 52;

  // Inputs
  static const double inputHeight = 54;

  // Chips
  static const double chipHeight = 34;

  // Navigation
  static const double bottomNavHeight = 80;
  static const double navPillHeight = 46;

  // Status bar (logical, mockup reference)
  static const double statusBarHeight = 52;

  // Avatars / icon tiles
  static const double iconTile = 44;
  static const double avatarMd = 46;

  // Canvas & container widths for responsive desktop, tablet and mobile layouts
  static const double refScreenWidth = 366; // inner content width reference
  static const double phoneMaxContentWidth = 480;
  static const double tabletMaxContentWidth = 900;
  static const double desktopMaxContentWidth = 1320;
  static const double maxContentWidth = desktopMaxContentWidth; // default container max width

  // Progress bars
  static const double trackHeight = 6;
}
