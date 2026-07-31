import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/order.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import 'widgets/summary_row.dart';

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDateTime(DateTime? d) {
  if (d == null) return '';
  final DateTime l = d.toLocal();
  int h = l.hour % 12;
  if (h == 0) h = 12;
  final String ampm = l.hour < 12 ? 'AM' : 'PM';
  final String mm = l.minute.toString().padLeft(2, '0');
  return '${l.day.toString().padLeft(2, '0')} ${_months[l.month - 1]} ${l.year} · $h:$mm $ampm';
}

String _mono(String title) {
  final String letters = title.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return 'GT';
  return letters
      .substring(0, letters.length >= 3 ? 3 : letters.length)
      .toUpperCase();
}

/// 34 · Order Detail — renders a past [OrderModel] from history.
///
/// Args: {order: OrderModel}.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final OrderModel? order =
        (args is Map && args['order'] is OrderModel) ? args['order'] as OrderModel : null;

    if (order == null) {
      return AppScaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Order not found',
            message: 'Open an order from your purchase history to see its details.',
            actionLabel: 'Purchase history',
            onAction: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.purchaseHistory),
          ),
        ),
      );
    }

    final OrderModel o = order;
    final bool paid = o.isPaid;
    final Color bannerBg = paid ? AppColors.successBg : AppColors.surfaceAlt;
    final Color bannerIcon = paid ? AppColors.success : AppColors.muted;
    final String bannerTitle =
        paid ? 'Payment successful · Access unlocked' : 'Order ${o.status.toLowerCase()}';
    final String bannerDate = _fmtDateTime(o.createdAt);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Order details',
                        style: AppTextStyles.titleSm
                            .copyWith(fontSize: 16, height: 1.2)),
                    const SizedBox(height: 1),
                    Text('#${o.orderNumber}',
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              children: <Widget>[
                // status banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  decoration: BoxDecoration(
                    color: bannerBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bannerIcon,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                            paid
                                ? Icons.check_rounded
                                : Icons.schedule_rounded,
                            size: 18,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(bannerTitle,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: paid
                                        ? const Color(0xFF14633F)
                                        : AppColors.ink)),
                            if (bannerDate.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 1),
                              Text(bannerDate,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: paid
                                          ? const Color(0xFF3F7A5E)
                                          : AppColors.muted)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _Label('Items'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < o.items.length; i++)
                        _ItemRow(
                          code: _mono(o.items[i].titleSnapshot),
                          title: o.items[i].titleSnapshot,
                          price: o.items[i].priceLabel(o.currency),
                          divider: i != o.items.length - 1,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _Label('Payment'),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: <Widget>[
                      SummaryRow(label: 'Subtotal', value: o.money(o.subtotalCents)),
                      if (o.discountCents > 0) ...<Widget>[
                        const SizedBox(height: 10),
                        SummaryRow(
                            label: 'Bundle discount',
                            value: '− ${o.money(o.discountCents)}',
                            valueColor: AppColors.signalRed),
                      ],
                      const SizedBox(height: 10),
                      SummaryRow(label: 'GST (18%)', value: o.money(o.taxCents)),
                      const SizedBox(height: 12),
                      const Divider(
                          height: 1, thickness: 1, color: Color(0xFFF0F2F7)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(paid ? 'Paid' : 'Total',
                              style: AppTextStyles.cardTitle
                                  .copyWith(fontWeight: FontWeight.w800)),
                          Text(o.totalLabel,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: AppColors.ink)),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7ECF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.lock_outline_rounded,
                                  size: 15, color: AppColors.navy),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Paid securely via Stripe',
                                      style: AppTextStyles.cardTitle
                                          .copyWith(fontSize: 12.5)),
                                  const SizedBox(height: 1),
                                  Text('Order #${o.orderNumber}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: _OutlineAction(
                          icon: Icons.description_outlined, label: 'Invoice'),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: _OutlineAction(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Get help',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.help)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.primaryButton,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.play_arrow_rounded,
                            size: 17, color: Colors.white),
                        SizedBox(width: 9),
                        Text('Go to course',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 11),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.muted)),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.code,
    required this.title,
    required this.price,
    this.divider = false,
  });

  final String code;
  final String title;
  final String price;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: Color(0xFFF0F2F7)))
            : null,
      ),
      child: Row(
        children: <Widget>[
          HatchTile(width: 46, height: 46, radius: 12, label: code),
          const SizedBox(width: 13),
          Expanded(
            child: Text(title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 13.5)),
          ),
          const SizedBox(width: 10),
          Text(price,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: AppColors.ink),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
