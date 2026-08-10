import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';

/// 32 · Empty Cart — state.
class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
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
                Text('Your Cart',
                    style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  "Add a subject or the full-year program and it'll show up here.",
              actionLabel: 'Browse the Store',
              onAction: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.store, (_) => false),
            ),
          ),
        ],
      ),
    );
  }
}
