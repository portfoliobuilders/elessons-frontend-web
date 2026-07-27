import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/primary_button.dart';
import '../../widgets/navigation/app_top_bar.dart';

/// 05 · Forgot Password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(_email.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      // In dev the backend echoes a reset token we can carry to the next
      // screen; in production the token arrives by email.
      Navigator.pushNamed(
        context,
        AppRoutes.resetPassword,
        arguments: {'token': auth.lastResetToken},
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(auth.error ?? 'Could not send the reset link.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.signalRed,
        ));
    }
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
              padding: const EdgeInsets.fromLTRB(30, 24, 30, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7ECF6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        size: 28, color: AppColors.navy),
                  ),
                  const SizedBox(height: 22),
                  Text('Forgot password?', style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your registered email and we'll send a secure link to reset it.",
                    style: AppTextStyles.bodyLg,
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'Email address',
                    icon: Icons.mail_outline_rounded,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Send reset link',
                    trailingArrow: true,
                    loading: _loading,
                    onPressed: _send,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_left,
                              size: 16, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text.rich(
                            TextSpan(
                              text: 'Back to ',
                              style: AppTextStyles.body.copyWith(
                                  fontSize: 13, color: AppColors.mutedAlt),
                              children: const [
                                TextSpan(
                                  text: 'Sign in',
                                  style: TextStyle(
                                      color: AppColors.navy,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
