import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../core/utils/responsive.dart';
import '../../models/api/cart_quote.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';
import 'widgets/summary_row.dart';

/// 16 · Cart — localized checkout, backed by [CartProvider].
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final currency = auth.user?.profile?.currency;
      context.read<CartProvider>().load(currency: currency);
    });
  }

  static const _countries = {'IN': 'India', 'AE': 'UAE', 'US': 'United States'};
  static const _symbols = {'INR': '₹', 'AED': 'د.إ', 'USD': '\$'};

  String _mono(String title) {
    final letters = title.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isEmpty) return 'GT';
    return letters.substring(0, letters.length >= 3 ? 3 : letters.length)
        .toUpperCase();
  }

  Future<void> _confirmRemove(CartProvider cart, QuoteLine line) async {
    await cart.remove(line.productId);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quote = cart.quote;
    final currency = quote.currency;
    final country = _countries[quote.region] ?? quote.region;
    final symbol = _symbols[currency] ?? currency;

    final loading = cart.status.isLoading && quote.isEmpty;
    final error = cart.status.isError && quote.isEmpty;

    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (Navigator.of(context).canPop())
                  _OutlineBack(onTap: () => Navigator.maybePop(context))
                else
                  const SizedBox(width: 42),
                Text('Your Cart',
                    style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
                GestureDetector(
                  onTap: quote.isEmpty
                      ? null
                      : () => context.read<CartProvider>().clear(),
                  child: Text('Clear',
                      style: AppTextStyles.heading.copyWith(
                          fontSize: 13,
                          color: quote.isEmpty
                              ? AppColors.muted
                              : AppColors.signalRed)),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const LoadingIndicator()
                : quote.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Your cart is empty',
                        message:
                            'Add a subject or the full-year bundle to get started.',
                        actionLabel: 'Browse courses',
                        onAction: () => Navigator.pushNamed(context, AppRoutes.store),
                      )
                    : error
                        ? EmptyState(
                            icon: Icons.wifi_off_rounded,
                            title: 'Something went wrong',
                            message: cart.error ?? 'Could not load your cart.',
                            actionLabel: 'Retry',
                            onAction: () => context.read<CartProvider>().load(),
                          )
                        : context.isDesktop
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 11),
                                            decoration: BoxDecoration(
                                              color: AppColors.divider,
                                              borderRadius: BorderRadius.circular(13),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                const Icon(Icons.public_rounded,
                                                    size: 17, color: AppColors.navy),
                                                const SizedBox(width: 9),
                                                Expanded(
                                                  child: Text(
                                                      'Prices localized for $country · $symbol $currency',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.navy)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(18),
                                              boxShadow: AppShadows.card,
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                for (int i = 0; i < quote.lines.length; i++)
                                                  _LineItem(
                                                    code: _mono(quote.lines[i].title),
                                                    title: quote.lines[i].title,
                                                    price: quote.lines[i].priceLabel(currency),
                                                    divider: i != quote.lines.length - 1,
                                                    onRemove: () => _confirmRemove(
                                                        context.read<CartProvider>(),
                                                        quote.lines[i]),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: AppShadows.card,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            SummaryRow(label: 'Subtotal', value: quote.subtotalLabel),
                                            if (quote.discountCents > 0) ...[
                                              const SizedBox(height: 11),
                                              SummaryRow(
                                                  label: 'Bundle discount',
                                                  value: '− ${quote.discountLabel}',
                                                  valueColor: AppColors.signalRed),
                                            ],
                                            const SizedBox(height: 11),
                                            SummaryRow(label: 'GST (18%)', value: quote.taxLabel),
                                            const SizedBox(height: 14),
                                            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F7)),
                                            const SizedBox(height: 14),
                                            SummaryRow(label: 'Total', value: quote.totalLabel, emphasize: true),
                                            const SizedBox(height: 20),
                                            GestureDetector(
                                              onTap: () => Navigator.pushNamed(context, AppRoutes.checkout),
                                              child: Container(
                                                height: 48,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: AppColors.navy,
                                                  borderRadius: BorderRadius.circular(AppRadius.input),
                                                  boxShadow: AppShadows.primaryButton,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    const Icon(Icons.lock_outline_rounded, size: 17, color: Colors.white),
                                                    const SizedBox(width: 9),
                                                    Text('Checkout · ${quote.totalLabel}',
                                                        style: const TextStyle(
                                                            fontSize: 15.5,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white)),
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
                              )
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                children: <Widget>[
                                  // region note
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: AppColors.divider,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(Icons.public_rounded,
                                            size: 17, color: AppColors.navy),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                              'Prices localized for $country · $symbol $currency',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.navy)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // line items
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: AppShadows.card,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        for (int i = 0;
                                            i < quote.lines.length;
                                            i++)
                                          _LineItem(
                                            code: _mono(quote.lines[i].title),
                                            title: quote.lines[i].title,
                                            price: quote.lines[i]
                                                .priceLabel(currency),
                                            divider:
                                                i != quote.lines.length - 1,
                                            onRemove: () => _confirmRemove(
                                                context.read<CartProvider>(),
                                                quote.lines[i]),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // promo
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 48,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(13),
                                            border: Border.all(
                                                color: const Color(0xFFE7EAF0),
                                                width: 1.5),
                                          ),
                                          child: Text('Promo code',
                                              style: AppTextStyles.body
                                                  .copyWith(color: AppColors.muted)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 84,
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE7ECF6),
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                        child: const Text('Apply',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.navy)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // summary
                                  Container(
                                    padding: const EdgeInsets.all(17),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: AppShadows.card,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        SummaryRow(
                                            label: 'Subtotal',
                                            value: quote.subtotalLabel),
                                        if (quote.discountCents > 0) ...[
                                          const SizedBox(height: 11),
                                          SummaryRow(
                                              label: 'Bundle discount',
                                              value: '− ${quote.discountLabel}',
                                              valueColor: AppColors.signalRed),
                                        ],
                                        const SizedBox(height: 11),
                                        SummaryRow(
                                            label: 'GST (18%)',
                                            value: quote.taxLabel),
                                        const SizedBox(height: 14),
                                        const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Color(0xFFF0F2F7)),
                                        const SizedBox(height: 14),
                                        SummaryRow(
                                            label: 'Total',
                                            value: quote.totalLabel,
                                            emphasize: true),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
          ),
          // sticky checkout
          if (!quote.isEmpty)
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
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.checkout),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        boxShadow: AppShadows.primaryButton,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.lock_outline_rounded,
                              size: 17, color: Colors.white),
                          const SizedBox(width: 9),
                          Text('Secure Checkout · ${quote.totalLabel}',
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text('Payments processed securely via Stripe',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({
    required this.code,
    required this.title,
    required this.price,
    this.divider = false,
    this.onRemove,
  });

  final String code;
  final String title;
  final String price;
  final bool divider;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: divider
              ? const Border(bottom: BorderSide(color: Color(0xFFF0F2F7)))
              : null,
        ),
        child: Row(
          children: <Widget>[
            HatchTile(width: 40, height: 40, radius: 10, label: code),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: AppTextStyles.cardTitle.copyWith(height: 1.25)),
            ),
            const SizedBox(width: 10),
            Text(price,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

class _OutlineBack extends StatelessWidget {
  const _OutlineBack({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE7EAF0), width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.chevron_left_rounded,
            size: 20, color: AppColors.ink),
      ),
    );
  }
}
