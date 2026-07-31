import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/razorpay_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import 'widgets/summary_row.dart';

enum _PayMethod { upi, card, netbanking }

/// 17 · Checkout — Razorpay Payment Screen.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PayMethod _method = _PayMethod.upi;

  String _mono(String title) {
    final letters = title.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isEmpty) return 'GT';
    return letters
        .substring(0, letters.length >= 3 ? 3 : letters.length)
        .toUpperCase();
  }

  void _showErrorDialog({
    required String title,
    required String message,
    IconData icon = Icons.error_outline_rounded,
    Color iconColor = AppColors.signalRed,
  }) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSm.copyWith(fontSize: 17),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pay() async {
    final razorpay = context.read<RazorpayProvider>();
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final user = auth.user;

    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      _showErrorDialog(
        title: 'Authentication Required',
        message: 'Please log in to complete checkout.',
        icon: Icons.lock_outline_rounded,
      );
      return;
    }

    final studentInfo = <String, dynamic>{
      'name': user?.name ?? 'Student',
      'phone': user?.profile?.parentPhone ?? '9876543210',
      'addressLine': user?.profile?.addressLine ?? 'Address',
      'city': user?.profile?.city ?? 'Kochi',
      'state': user?.profile?.state ?? 'Kerala',
      'pincode': user?.profile?.pincode ?? '682001',
      'currency': cart.quote.currency.isNotEmpty ? cart.quote.currency : 'INR',
    };

    try {
      await razorpay.startCartCheckout(
        accessToken: token,
        studentInfo: studentInfo,
        studentPhone: user?.profile?.parentPhone ?? '9876543210',
        studentEmail: user?.email,
      );
    } catch (e) {
      razorpay.reset();
      _showErrorDialog(
        title: 'Checkout Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final razorpay = context.watch<RazorpayProvider>();
    final quote = cart.quote;
    final lines = quote.lines;
    final count = lines.length;
    final gradeName = auth.user?.profile?.gradeName ?? '';
    final board = auth.user?.profile?.board ?? '';
    final ctx = [gradeName, board].where((e) => e.isNotEmpty).join(' ');
    final firstTitle = lines.isNotEmpty ? lines.first.title : 'Your order';
    final summaryTitle = count > 1 ? '$firstTitle + ${count - 1} more' : firstTitle;
    final summaryMeta =
        ctx.isEmpty ? '$count item${count == 1 ? '' : 's'}' : '$count item${count == 1 ? '' : 's'} · $ctx';

    // Reactively handle Razorpay payment states
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (razorpay.isSuccess) {
        final String orderNum = razorpay.activeOrder?.orderNumber ??
            (razorpay.verificationResult?['orderNumber']?.toString() ?? 'GT-2026-PAYMENT');
        debugPrint('🎉 [CheckoutScreen]: Payment success detected! Navigating to Order Confirmed ($orderNum)...');
        razorpay.reset();
        cart.load(); // refresh or clear cart
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.orderConfirmed,
          (Route<dynamic> r) => r.settings.name == AppRoutes.home,
          arguments: {'orderNumber': orderNum},
        );
      } else if (razorpay.isFailure) {
        final String err = razorpay.errorMessage ?? 'Payment failed. Please try again.';
        debugPrint('❌ [CheckoutScreen]: Payment failure detected: $err');
        razorpay.reset();
        _showErrorDialog(
          title: 'Payment Error',
          message: err,
        );
      } else if (razorpay.isCancelled) {
        debugPrint('⚠️ [CheckoutScreen]: Payment cancellation detected.');
        razorpay.reset();
        _showErrorDialog(
          title: 'Payment Cancelled',
          message: 'The payment process was cancelled.',
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF59E0B),
        );
      }
    });

    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFE7EAF0), width: 1.5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        size: 20, color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Checkout',
                    style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: <Widget>[
                // Order summary collapsed
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: <Widget>[
                      HatchTile(width: 40, height: 40, radius: 10, label: _mono(firstTitle)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(summaryTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle
                                    .copyWith(fontSize: 13.5)),
                            const SizedBox(height: 1),
                            Text(summaryMeta,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ),
                      Text(quote.totalLabel,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 11),
                  child: Text('PAY USING RAZORPAY',
                      style: AppTextStyles.overline.copyWith(
                          fontSize: 12,
                          letterSpacing: 0.6,
                          color: AppColors.muted)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: <Widget>[
                      _PayOption(
                        icon: Icons.smartphone_rounded,
                        title: 'UPI',
                        subtitle: 'Google Pay · PhonePe · Paytm · BHIM',
                        selected: _method == _PayMethod.upi,
                        onTap: () => setState(() => _method = _PayMethod.upi),
                      ),
                      _PayOption(
                        icon: Icons.credit_card_rounded,
                        title: 'Credit / Debit card',
                        subtitle: 'Visa, Mastercard, RuPay',
                        selected: _method == _PayMethod.card,
                        topBorder: true,
                        onTap: () => setState(() => _method = _PayMethod.card),
                      ),
                      _PayOption(
                        icon: Icons.account_balance_rounded,
                        title: 'Netbanking',
                        subtitle: 'SBI, HDFC, ICICI, Axis & all major banks',
                        selected: _method == _PayMethod.netbanking,
                        topBorder: true,
                        onTap: () =>
                            setState(() => _method = _PayMethod.netbanking),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: <Widget>[
                      SummaryRow(label: 'Subtotal', value: quote.subtotalLabel),
                      if (quote.discountCents > 0) ...[
                        const SizedBox(height: 10),
                        SummaryRow(
                            label: 'Bundle discount',
                            value: '− ${quote.discountLabel}',
                            valueColor: AppColors.signalRed),
                      ],
                      const SizedBox(height: 10),
                      SummaryRow(label: 'GST (18%)', value: quote.taxLabel),
                      const SizedBox(height: 12),
                      const Divider(
                          height: 1, thickness: 1, color: Color(0xFFF0F2F7)),
                      const SizedBox(height: 12),
                      SummaryRow(
                          label: 'Total payable',
                          value: quote.totalLabel,
                          emphasize: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: razorpay.isLoading
                      ? () {
                          razorpay.reset();
                          _showErrorDialog(
                            title: 'Payment Stopped',
                            message: 'Payment loading was manually cancelled.',
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.navy,
                          );
                        }
                      : _pay,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      boxShadow: AppShadows.primaryButton,
                    ),
                    child: razorpay.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.lock_outline_rounded,
                                  size: 17, color: Colors.white),
                              const SizedBox(width: 9),
                              Text('Pay ${quote.totalLabel} via Razorpay',
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 9),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.shield_outlined,
                        size: 13, color: AppColors.muted),
                    SizedBox(width: 7),
                    Text('256-bit encrypted · powered by Razorpay',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.topBorder = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: selected
              ? Border.all(color: AppColors.navy, width: 2)
              : (topBorder
                  ? const Border(top: BorderSide(color: Color(0xFFF0F2F7)))
                  : null),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE7ECF6) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
