import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/cart_quote.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import 'widgets/summary_row.dart';

/// 18 · Order Confirmed — reached after the Stripe hand-off in [CheckoutScreen].
///
/// Args: {orderNumber}. The paid amount and item summary are read from the
/// cart quote that was just checked out (still resident until the next reload).
class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String orderNumber =
        (args is Map ? args['orderNumber'] as String? : null) ?? '';
    final quote = context.watch<CartProvider>().quote;
    final List<QuoteLine> lines = quote.lines;
    final int count = lines.length;
    final String itemsSummary = count == 0
        ? 'Your courses'
        : (count == 1
            ? lines.first.title
            : '${lines.first.title} + ${count - 1} more');
    final String amountLabel = quote.totalLabel;
    final String orderIdLabel = orderNumber.isEmpty ? '—' : '#$orderNumber';
    return AppScaffold(
      safeTop: false,
      safeBottom: false,
      dark: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // navy success hero
          SizedBox(
            height: 430,
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppGradients.heroCard),
              child: ClipRect(
                child: Stack(
                  children: <Widget>[
                    const Positioned(
                      top: -50,
                      right: -40,
                      child: _Blob(size: 200, opacity: 0.05),
                    ),
                    const Positioned(
                      bottom: -30,
                      left: -40,
                      child: _Blob(size: 160, opacity: 0.04),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 96,
                              height: 96,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 36, color: AppColors.navy),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text('Payment successful',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            const Text(
                              'Your courses are unlocked and ready in\nMy Learnings.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: AppColors.onNavySubtle),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                  26, 24, 26, 26 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: <Widget>[
                        SummaryRow(label: 'Order ID', value: orderIdLabel),
                        const SizedBox(height: 12),
                        SummaryRow(label: 'Items', value: itemsSummary),
                        const SizedBox(height: 12),
                        const Divider(
                            height: 1, thickness: 1, color: AppColors.divider),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Amount paid',
                                style: AppTextStyles.cardTitle
                                    .copyWith(fontWeight: FontWeight.w800)),
                            Text(amountLabel,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.lock_outline_rounded,
                          size: 15, color: AppColors.muted),
                      SizedBox(width: 9),
                      Text('Receipt emailed · paid via Stripe',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.home, (_) => false),
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        boxShadow: AppShadows.primaryButton,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.play_arrow_rounded,
                              size: 18, color: Colors.white),
                          SizedBox(width: 9),
                          Text('Start learning',
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.purchaseHistory),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Text('View receipt',
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink)),
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

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
