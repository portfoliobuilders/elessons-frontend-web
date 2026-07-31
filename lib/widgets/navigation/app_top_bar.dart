import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import 'package:flutter/services.dart';
import '../common/icon_tile_button.dart';

/// Lightweight in-content top bar: bordered back button, centered title, and
/// optional trailing actions. (Used instead of a Material AppBar so spacing
/// matches the design precisely.)
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.onBack,
    this.actions = const [],
    this.showBack = true,
    this.dark = false,
  });

  final String? title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showBack;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    return SystemUiOverlayStyleAnnotation(
      dark: dark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            if (showBack)
              IconTileButton(
                icon: Icons.chevron_left,
                iconSize: 24,
                bordered: !dark,
                background: dark ? Colors.white.withValues(alpha: 0.12) : AppColors.surfaceAlt,
                iconColor: fg,
                size: 42,
                onTap: onBack ?? () => Navigator.maybePop(context),
              )
            else
              const SizedBox(width: 42),
            Expanded(
              child: Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSm.copyWith(color: fg),
              ),
            ),
            if (actions.isEmpty)
              const SizedBox(width: 42)
            else
              Row(mainAxisSize: MainAxisSize.min, children: actions),
          ],
        ),
      ),
    );
  }
}

/// Applies the correct status-bar icon brightness for the current header.
class SystemUiOverlayStyleAnnotation extends StatelessWidget {
  const SystemUiOverlayStyleAnnotation({
    super.key,
    required this.child,
    required this.dark,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: child,
    );
  }
}
