import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/theme/colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_footer.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/auth/auth_textfield.dart';
import '../../widgets/inputs/social_button.dart';

/// Redesigned SaaS-Style Create Account / Registration Screen.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;
  bool _parentNumber = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Normalise to the E.164-ish shape the backend OTP DTO expects
  /// (digits only, prefixed with +91). "98765 43210" -> "+919876543210".
  String _normalizedPhone() {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('91') && digits.length > 10) return '+$digits';
    return '+91$digits';
  }

  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final phone = _normalizedPhone();
    final ok = await auth.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phone: phone.isEmpty ? null : phone,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushNamed(context, AppRoutes.otp, arguments: {'phone': phone});
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(auth.error ?? 'Could not create your account.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.signalRed,
        ));
    }
  }

  Future<void> _social(String provider) async {
    if (provider == 'google') {
      try {
        setState(() => _loading = true);
        final googleSignIn = GoogleSignIn(
          clientId: 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        );
        final account = await googleSignIn.signIn();
        if (account == null) {
          setState(() => _loading = false);
          return;
        }
        final auth = await account.authentication;
        if (auth.idToken != null) {
          if (!mounted) return;
          final authProv = context.read<AuthProvider>();
          final ok = await authProv.google(auth.idToken!);
          if (!mounted) return;
          setState(() => _loading = false);
          if (ok) {
            final route =
                authProv.isOnboarded ? AppRoutes.home : AppRoutes.onboardBoard;
            Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(authProv.error ?? 'Google sign in failed.'),
                backgroundColor: AppColors.signalRed,
              ));
          }
        } else {
          setState(() => _loading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text('Google sign in error: $e'),
                backgroundColor: AppColors.signalRed));
        }
      }
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Apple sign-in needs native setup.'),
            backgroundColor: AppColors.signalRed,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      lottiePath: 'assets/lottie/login.json',
      childCard: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthHeader(
              title: 'Create Your Account',
              subtitle: 'Please fill in your details to continue.',
            ),
            const SizedBox(height: 28),

            AuthTextField(
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              controller: _name,
              keyboardType: TextInputType.name,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            AuthTextField(
              label: 'Email Address',
              icon: Icons.mail_outline_rounded,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _MobileField(
              controller: _phone,
              parentSelected: _parentNumber,
              onToggle: (v) => setState(() => _parentNumber = v),
            ),
            const SizedBox(height: 16),

            AuthTextField(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              controller: _password,
              isPassword: true,
            ),
            const SizedBox(height: 18),

            _TermsCheck(
              value: _agreed,
              onChanged: () => setState(() => _agreed = !_agreed),
            ),
            const SizedBox(height: 24),

            AuthButton(
              label: 'Create Account',
              loading: _loading,
              enabled: _agreed,
              onPressed: _agreed ? _create : null,
            ),
            const SizedBox(height: 20),

            // ── Social Sign Up ──
            Row(
              children: [
                Expanded(
                  child: SocialButton(
                    label: 'Google',
                    glyph: const GoogleGlyph(),
                    onTap: () => _social('google'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SocialButton(
                    label: 'Apple',
                    glyph: const AppleGlyph(),
                    onTap: () => _social('apple'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Divider(color: Color(0xFFE5E5E5), height: 1),
            const SizedBox(height: 20),

            AuthFooter(
              promptText: 'Already have an account?',
              actionText: 'Login',
              onActionTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.login,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phone-number field with country-code prefix and Mine / Parent's toggle.
class _MobileField extends StatelessWidget {
  const _MobileField({
    required this.controller,
    required this.parentSelected,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool parentSelected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _seg('Mine', !parentSelected, () => onToggle(false)),
                  _seg("Parent's", parentSelected, () => onToggle(true)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                width: 62,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6FA),
                  border: Border(
                    right: BorderSide(color: Color(0xFFE5E5E5), width: 1.2),
                  ),
                ),
                child: const Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    cursorColor: const Color(0xFF222222),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222),
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Enter phone number',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF222222) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }
}

class _TermsCheck extends StatelessWidget {
  const _TermsCheck({required this.value, required this.onChanged});
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF222222) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: value
                  ? null
                  : Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
