import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

/// Reusable responsive grid container widget that auto-adjusts column count
/// based on viewport width (Mobile: 1 col, Tablet: 2 cols, Desktop: 3-4 cols).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.phoneCols = 1,
    this.tabletCols = 2,
    this.desktopCols = 3,
    this.wideDesktopCols,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int phoneCols;
  final int tabletCols;
  final int desktopCols;
  final int? wideDesktopCols;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final cols = context.gridCrossAxisCount(
      phone: phoneCols,
      tablet: tabletCols,
      desktop: desktopCols,
      wideDesktop: wideDesktopCols,
    );

    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
