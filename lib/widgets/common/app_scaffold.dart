import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/responsive.dart';

/// App-wide scaffold wrapper.
///
/// * Applies the correct status-bar icon brightness ([dark] => light icons).
/// * Centres + clamps content width on tablets / iPads / desktop so the
///   phone-first composition is preserved rather than stretched.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.backgroundColor = AppColors.white,
    this.bottomNavigationBar,
    this.dark = false,
    this.safeTop = true,
    this.safeBottom = true,
    this.clampWidth = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final Color backgroundColor;
  final Widget? bottomNavigationBar;
  final bool dark;
  final bool safeTop;
  final bool safeBottom;
  final bool clampWidth;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      top: safeTop,
      bottom: safeBottom && bottomNavigationBar == null,
      child: body,
    );

    if (clampWidth && context.isLargeScreen) {
      content = ResponsiveCenter(child: content);
    }

    final showBottomNav = bottomNavigationBar != null && !context.isDesktop;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        bottomNavigationBar: showBottomNav ? bottomNavigationBar : null,
        body: content,
      ),
    );
  }
}
