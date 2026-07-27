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

/// Redesigned SaaS-Style Login / Sign-in Screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _goNext(auth);
    } else {
      _showError(auth.error ?? 'Sign in failed. Please try again.');
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
            _goNext(authProv);
          } else {
            _showError(authProv.error ?? 'Google sign in failed');
          }
        } else {
          setState(() => _loading = false);
          _showError('Could not retrieve Google ID token.');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          _showError('Google sign in error: $e');
        }
      }
    } else {
      _showError(
        'Apple sign-in needs native setup. Use email & password for now.',
      );
    }
  }

  void _goNext(AuthProvider auth) {
    final route =
        auth.isOnboarded ? AppRoutes.home : AppRoutes.onboardBoard;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.signalRed,
      ));
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
              title: 'Welcome Back!',
              subtitle: 'Sign in to continue to your account.',
            ),
            const SizedBox(height: 32),

            AuthTextField(
              label: 'Email Address',
              icon: Icons.mail_outline_rounded,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
            const SizedBox(height: 20),

            AuthTextField(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              controller: _password,
              isPassword: true,
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.forgotPassword,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            AuthButton(
              label: 'Login',
              loading: _loading,
              onPressed: _signIn,
            ),

            const SizedBox(height: 24),

            // ── Social Sign In ──
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
            const SizedBox(height: 28),

            const Divider(color: Color(0xFFE5E5E5), height: 1),
            const SizedBox(height: 24),

            AuthFooter(
              promptText: "Don't have an account?",
              actionText: 'Sign Up',
              onActionTap: () => Navigator.pushNamed(
                context,
                AppRoutes.createAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
