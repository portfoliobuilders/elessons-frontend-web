import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';

/// Primary navy CTA. Supports a trailing arrow, loading state, and a press
/// scale micro-interaction. Matches the design's `Get started` / `Sign in`.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingArrow = false,
    this.icon,
    this.loading = false,
    this.height = AppDimensions.buttonHeight,
    this.background = AppColors.navy,
    this.foreground = AppColors.white,
    this.enabled = true,
    this.shadow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool trailingArrow;
  final IconData? icon;
  final bool loading;
  final double height;
  final Color background;
  final Color foreground;
  final bool enabled;
  final bool shadow;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  bool get _interactive =>
      widget.enabled && !widget.loading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _interactive ? (_) => setState(() => _down = true) : null,
      onTapUp: _interactive ? (_) => setState(() => _down = false) : null,
      onTapCancel: _interactive ? () => setState(() => _down = false) : null,
      onTap: _interactive ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1 : 0.5,
          duration: const Duration(milliseconds: 150),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(AppRadius.input),
              boxShadow: widget.shadow ? AppShadows.primaryButton : null,
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(widget.foreground),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: widget.foreground),
                        const SizedBox(width: 9),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.button.copyWith(color: widget.foreground),
                      ),
                      if (widget.trailingArrow) ...[
                        const SizedBox(width: 9),
                        Icon(Icons.arrow_forward, size: 18, color: widget.foreground),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
