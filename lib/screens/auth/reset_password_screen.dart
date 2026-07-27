import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/primary_button.dart';
import '../../widgets/navigation/app_top_bar.dart';

/// 06 · Reset Password.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _token;
  bool _argsRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['token'] is String) {
      _token = args['token'] as String;
    }
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// 0..4 — simplistic strength heuristic for the meter.
  int get _strength {
    final p = _password.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p) || p.length >= 12) score++;
    return score.clamp(0, 4);
  }

  String get _strengthLabel {
    switch (_strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      default:
        return 'Very strong';
    }
  }

  Color get _strengthColor =>
      _strength <= 1 ? AppColors.signalRed : AppColors.success;

  bool get _matches =>
      _confirm.text.isNotEmpty && _confirm.text == _password.text;

  Future<void> _reset() async {
    FocusScope.of(context).unfocus();
    if (!_matches) {
      _snack('Passwords do not match.');
      return;
    }
    final token = _token;
    if (token == null || token.isEmpty) {
      _snack('Open the reset link from your email to continue.');
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(token: token, newPassword: _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Password updated. Please sign in.'),
          behavior: SnackBarBehavior.floating,
        ));
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    } else {
      _snack(auth.error ?? 'Could not reset your password.');
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.signalRed,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const AppTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 22, 30, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set a new password', style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text(
                    "Create a strong password you'll remember. Minimum 8 characters.",
                    style: AppTextStyles.bodyLg,
                  ),
                  const SizedBox(height: 26),
                  AppTextField(
                    label: 'New password',
                    icon: Icons.lock_outline_rounded,
                    controller: _password,
                    obscure: true,
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  _StrengthMeter(
                    score: _strength,
                    label: _strengthLabel,
                    color: _strengthColor,
                  ),
                  const SizedBox(height: 20),
                  _ConfirmField(
                    controller: _confirm,
                    matches: _matches,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Reset password',
                    loading: _loading,
                    onPressed: _reset,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({
    required this.score,
    required this.label,
    required this.color,
  });

  final int score;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < score ? color : const Color(0xFFE7EAF0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i != 3) const SizedBox(width: 5),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11.5,
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Confirm-password field that shows a green check when it matches.
class _ConfirmField extends StatefulWidget {
  const _ConfirmField({
    required this.controller,
    required this.matches,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool matches;
  final VoidCallback onChanged;

  @override
  State<_ConfirmField> createState() => _ConfirmFieldState();
}

class _ConfirmFieldState extends State<_ConfirmField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm password', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 19, color: AppColors.muted),
              const SizedBox(width: 11),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscured,
                  cursorColor: AppColors.navy,
                  onChanged: (_) => widget.onChanged(),
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (widget.matches)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: AppColors.success),
                )
              else
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
