import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// A label/value row used across the cart, checkout and order screens for
/// price breakdowns. [emphasize] renders the bolder "Total" treatment.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label,
            style: TextStyle(
                fontSize: emphasize ? 15 : 13.5,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
                color: emphasize ? AppColors.ink : AppColors.mutedAlt)),
        Text(value,
            style: TextStyle(
                fontSize: emphasize ? 21 : 13.5,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: emphasize ? -0.4 : 0,
                color: valueColor ?? AppColors.ink)),
      ],
    );
  }
}
