import 'package:flutter/widgets.dart';
import '../theme/app_dimensions.dart';

/// Device-class breakpoints & helpers for responsive Web, Desktop, Tablet, and Mobile.
enum DeviceType { phone, tablet, desktop }

extension ResponsiveContext on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);
  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  DeviceType get deviceType {
    final w = screenWidth;
    if (w >= 1024) return DeviceType.desktop;
    if (w >= 600) return DeviceType.tablet;
    return DeviceType.phone;
  }

  bool get isPhone => deviceType == DeviceType.phone;
  bool get isMobile => isPhone;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isLargeScreen => !isPhone;

  /// Optimal max container width for current viewport.
  double get responsiveMaxWidth {
    switch (deviceType) {
      case DeviceType.desktop:
        return AppDimensions.desktopMaxContentWidth;
      case DeviceType.tablet:
        return AppDimensions.tabletMaxContentWidth;
      case DeviceType.phone:
        return AppDimensions.phoneMaxContentWidth;
    }
  }

  /// Calculates cross-axis column count for responsive grid layouts.
  int gridCrossAxisCount({
    int phone = 1,
    int tablet = 2,
    int desktop = 3,
    int? wideDesktop,
  }) {
    if (screenWidth >= 1600 && wideDesktop != null) return wideDesktop;
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.phone:
        return phone;
    }
  }

  /// Pick a value per device class.
  T responsive<T>({required T phone, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }
}

/// Constrains content to a comfortable centered column on desktop / tablet / mobile.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.color,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? context.responsiveMaxWidth;
    return Container(
      color: color,
      padding: padding,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }
}

