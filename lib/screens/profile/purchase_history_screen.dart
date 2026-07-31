import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/view_status.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  final DateTime l = d.toLocal();
  return '${l.day.toString().padLeft(2, '0')} ${_months[l.month - 1]} ${l.year}';
}

String _mono(String title) {
  final String letters = title.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return 'GT';
  return letters
      .substring(0, letters.length >= 3 ? 3 : letters.length)
      .toUpperCase();
}

/// 30 · Purchase History — bound to GET /me/orders.
class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<OrderProvider>().loadOrders());
  }

  Future<void> _reload() => context.read<OrderProvider>().loadOrders();

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
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
                Text('Purchase History',
                    style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Expanded(child: _body(order)),
        ],
      ),
    );
  }

  Widget _body(OrderProvider order) {
    if (order.status == ViewStatus.loading && order.orders.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    if (order.status == ViewStatus.error && order.orders.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: "Couldn't load your orders",
          message: order.error ?? 'Please try again.',
          actionLabel: 'Retry',
          onAction: _reload,
        ),
      );
    }
    if (order.orders.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No purchases yet',
          message: 'Courses you buy will show up here with their invoices.',
          actionLabel: 'Browse courses',
          onAction: () =>
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.store, (_) => false),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _reload,
      color: AppColors.navy,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        itemCount: order.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int i) {
          final OrderModel o = order.orders[i];
          final String date = _fmtDate(o.createdAt);
          return _OrderCard(
            date: date.isEmpty ? '#${o.orderNumber}' : '$date · #${o.orderNumber}',
            amount: o.totalLabel,
            status: o.status,
            lines: o.items
                .map((OrderItemModel it) => _OrderLine(
                      _mono(it.titleSnapshot),
                      it.titleSnapshot,
                      it.priceLabel(o.currency),
                    ))
                .toList(),
            onInvoice: () => Navigator.pushNamed(
              context,
              AppRoutes.orderDetail,
              arguments: <String, dynamic>{'order': o},
            ),
            onStart: () => Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
          );
        },
      ),
    );
  }
}

class _OrderLine {
  const _OrderLine(this.code, this.title, this.price);
  final String code;
  final String title;
  final String price;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.date,
    required this.amount,
    required this.status,
    required this.lines,
    required this.onInvoice,
    required this.onStart,
  });

  final String date;
  final String amount;
  final String status;
  final List<_OrderLine> lines;
  final VoidCallback onInvoice;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bool paid = status == 'PAID';
    final Color badgeBg = paid ? AppColors.successBg : AppColors.surfaceAlt;
    final Color badgeFg = paid ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(date,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text(amount,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: badgeFg)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F7)),
          const SizedBox(height: 12),
          ...lines.map((_OrderLine l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    HatchTile(width: 40, height: 40, radius: 11, label: l.code),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l.title,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    Text(l.price,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: onInvoice,
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.description_outlined,
                            size: 15, color: AppColors.ink),
                        SizedBox(width: 7),
                        Text('Invoice',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onStart,
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7ECF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Start learning',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
