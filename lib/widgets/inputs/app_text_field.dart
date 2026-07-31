import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';

/// Bordered input field with a leading icon and an optional trailing widget
/// (e.g. password visibility toggle). The border turns navy + casts a soft
/// shadow on focus, exactly as in the design.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
    this.onTrailingTap,
    this.letterSpacing,
    this.autofocus = false,
    this.showObscureToggle = true,
  });

  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? trailing;
  final VoidCallback? onTrailingTap;
  final double? letterSpacing;
  final bool autofocus;

  /// When the field is a password ([obscure] true) this renders an eye toggle.
  final bool showObscureToggle;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _node = FocusNode()..addListener(_onFocus);
  bool _focused = false;
  late bool _obscured = widget.obscure;

  void _onFocus() => setState(() => _focused = _node.hasFocus);

  @override
  void dispose() {
    _node.removeListener(_onFocus);
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: AppDimensions.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: _focused ? AppColors.navy : AppColors.border,
              width: 1.5,
            ),
            boxShadow: _focused ? AppShadows.focusedInput : null,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 19,
                  color: _focused ? AppColors.navy : AppColors.muted,
                ),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: TextField(
                  focusNode: _node,
                  controller: widget.controller,
                  obscureText: _obscured,
                  keyboardType: widget.keyboardType,
                  autofocus: widget.autofocus,
                  cursorColor: AppColors.navy,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: widget.letterSpacing,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.heading.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
              if (widget.obscure && widget.showObscureToggle)
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: AppColors.muted,
                  ),
                )
              else if (widget.trailing != null)
                GestureDetector(
                  onTap: widget.onTrailingTap,
                  child: Icon(widget.trailing, size: 19, color: AppColors.muted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
