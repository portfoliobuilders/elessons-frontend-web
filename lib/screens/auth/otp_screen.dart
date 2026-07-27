import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/inputs/primary_button.dart';
import '../../widgets/navigation/app_top_bar.dart';

/// 04 · OTP Verification.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _length = 6;
  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(_length, (_) => FocusNode());

  Timer? _timer;
  int _seconds = 24;
  bool _loading = false;
  String _phone = '';
  bool _argsRead = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['phone'] is String) {
      _phone = args['phone'] as String;
    }
    if (_phone.isNotEmpty) {
      // Trigger the code send; in dev the backend echoes it so we auto-fill.
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestCode());
    }
  }

  Future<void> _requestCode() async {
    final devCode = await context.read<AuthProvider>().requestOtp(_phone);
    if (!mounted) return;
    if (devCode != null && devCode.length == _length) {
      for (int i = 0; i < _length; i++) {
        _controllers[i].text = devCode[i];
      }
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 24);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < _length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (_code.length < _length) {
      _snack('Enter the full 6-digit code.');
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    // If we never had a phone (edge case), the account is already signed in
    // from registration — just continue to onboarding.
    final ok = _phone.isEmpty
        ? true
        : await auth.verifyOtp(phone: _phone, code: _code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      final route =
          auth.isOnboarded ? AppRoutes.home : AppRoutes.onboardBoard;
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    } else {
      _snack(auth.error ?? 'That code didn\'t match. Please try again.');
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

  Future<void> _resend() async {
    if (_seconds > 0) return;
    if (_phone.isNotEmpty) await _requestCode();
    _startTimer();
  }

  String get _countdown {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
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
                    child: const Icon(Icons.mail_outline_rounded,
                        size: 28, color: AppColors.navy),
                  ),
                  const SizedBox(height: 22),
                  Text('Verify your number', style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: 'Enter the 6-digit code sent to\n',
                      style: AppTextStyles.bodyLg,
                      children: [
                        TextSpan(
                          text: _phone.isEmpty ? 'your number' : _phone,
                          style: const TextStyle(
                              color: AppColors.ink, fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' · '),
                        const TextSpan(
                          text: 'Change',
                          style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      for (int i = 0; i < _length; i++) ...[
                        Expanded(child: _otpBox(i)),
                        if (i != _length - 1) const SizedBox(width: 10),
                      ],
                    ],
                  ),
                  const SizedBox(height: 26),
                  _seconds > 0
                      ? Text.rich(
                          TextSpan(
                            text: "Didn't get it? Resend in ",
                            style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: _countdown,
                                style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: _resend,
                          child: Text(
                            'Resend code',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              color: AppColors.navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    label: 'Verify & continue',
                    trailingArrow: true,
                    loading: _loading,
                    onPressed: _verify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int i) {
    final filled = _controllers[i].text.isNotEmpty;
    final focused = _nodes[i].hasFocus;
    final active = filled || focused;
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFAFBFE) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: active ? AppColors.navy : AppColors.border,
            width: active ? 2 : 1.5,
          ),
        ),
        child: TextField(
          controller: _controllers[i],
          focusNode: _nodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: AppColors.navy,
          showCursor: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.display.copyWith(fontSize: 24),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isCollapsed: true,
          ),
          onChanged: (v) => _onChanged(i, v),
        ),
      ),
    );
  }
}
