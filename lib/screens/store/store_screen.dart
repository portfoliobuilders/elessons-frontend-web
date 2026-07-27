import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/responsive_grid.dart';
import '../../models/subject.dart';
import '../../models/api/catalog.dart';
import '../../models/api/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/icon_tile_button.dart';
import '../../widgets/cards/subject_card.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

/// 13 · Store — Browse by Subject. Rendered as the second tab of [HomeShell].
///
/// Consumes the same [HomeProvider] grade data as the Home tab (subjects are
/// enriched with chapter/lesson counts + subject-level prices). The bundle hero
/// binds to the grade's FULL_CLASS product.
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStore();
    });
  }

  Future<void> _refreshStore() async {
    final gradeId = context.read<AuthProvider>().user?.profile?.gradeId;
    await context.read<HomeProvider>().refresh(gradeId: gradeId);
  }

  Subject _toView(SubjectModel s) {
    int priceFrom = 0;
    for (final p in s.products) {
      final price = p.priceFor();
      if (price != null) {
        final rupees = (price.amountCents / 100).round();
        if (priceFrom == 0 || rupees < priceFrom) priceFrom = rupees;
      }
    }
    return Subject(
      code: s.monogram,
      name: s.name,
      modules: s.chapterCount,
      lessons: s.lessonCount,
      priceFrom: priceFrom,
    );
  }

  Product? _fullClassProduct(HomeProvider home) {
    final products = home.grade?.products ?? const <Product>[];
    for (final p in products) {
      if (p.type == 'FULL_CLASS') return p;
    }
    return null;
  }

  String _regionChipLabel(String region, String currency) {
    const countries = {'IN': 'India', 'AE': 'UAE', 'US': 'United States'};
    const symbols = {'INR': '₹', 'AED': 'د.إ', 'USD': '\$'};
    final country = countries[region] ?? region;
    final symbol = symbols[currency] ?? currency;
    return '$country · $symbol $currency';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final home = context.watch<HomeProvider>();
    final profile = auth.user?.profile;
    final gradeId = profile?.gradeId;
    final gradeName = profile?.gradeName ?? home.grade?.name ?? 'Class 10';
    final board = profile?.board ?? home.grade?.board ?? 'CBSE';
    final region = profile?.region ?? 'IN';
    final currency = profile?.currency ?? 'INR';

    final subjects = home.subjects;
    final loadingContent = home.status.isLoading && subjects.isEmpty;
    final errorContent = home.status.isError && subjects.isEmpty;
    final bundle = _fullClassProduct(home);
    final totalLessons =
        subjects.fold<int>(0, (sum, s) => sum + s.lessonCount);

    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: _refreshStore,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Store',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      )),
                  const SizedBox(height: 1),
                  Text('What will you learn?',
                      style: AppTextStyles.display.copyWith(fontSize: 25)),
                ],
              ),
            ),
            IconTileButton(
              icon: Icons.notifications_none_rounded,
              size: 46,
              showDot: true,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          size: 19, color: AppColors.muted),
                      const SizedBox(width: 10),
                      Text('Search subjects, chapters…',
                          style: AppTextStyles.body.copyWith(
                              fontSize: 14, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: const Icon(Icons.tune_rounded,
                  size: 20, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _ContextChip(
              label: _regionChipLabel(region, currency),
              leading: Icons.public_rounded,
            ),
            const SizedBox(width: 8),
            _ContextChip(
              label: '$gradeName · $board',
              trailing: Icons.keyboard_arrow_down_rounded,
              filled: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (bundle != null) ...[
          _BundleHeroCard(
            title: '$gradeName · $board\nFull Year Program',
            meta: totalLessons > 0
                ? '${subjects.length} subjects · $totalLessons+ lessons'
                : '${subjects.length} subjects',
            price: bundle.priceFor(region: region, currency: currency),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.courseDetail,
              arguments: {'gradeId': gradeId, 'productId': bundle.id},
            ),
          ),
          const SizedBox(height: 26),
        ],
        Row(
          children: [
            Expanded(
              child: Text('Browse by Subject',
                  style: AppTextStyles.sectionTitle),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (loadingContent)
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: LoadingIndicator(),
          )
        else if (errorContent)
          EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Something went wrong',
            message: home.error ?? 'Could not load the store.',
            actionLabel: 'Retry',
            onAction: () => home.refresh(gradeId: gradeId),
          )
        else if (subjects.isEmpty)
          const EmptyState(
            icon: Icons.storefront_outlined,
            title: 'Nothing here yet',
            message: 'Subjects for your class will appear here soon.',
          )
        else
          _grid(context, subjects, gradeId),
      ],
    ),
  );
  }

  Widget _grid(BuildContext context, List<SubjectModel> subjects, String? gradeId) {
    if (context.isDesktop || context.isTablet) {
      return ResponsiveGrid(
        itemCount: subjects.length,
        phoneCols: 1,
        tabletCols: 2,
        desktopCols: 3,
        wideDesktopCols: 4,
        childAspectRatio: 1.55,
        itemBuilder: (context, i) => SubjectCard(
          subject: _toView(subjects[i]),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.courseDetail,
            arguments: {'subjectId': subjects[i].id, 'gradeId': gradeId},
          ),
        ),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < subjects.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SubjectCard(
              subject: _toView(subjects[i]),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.courseDetail,
                arguments: {'subjectId': subjects[i].id, 'gradeId': gradeId},
              ),
            ),
          ),
          const SizedBox(width: 13),
          if (i + 1 < subjects.length)
            Expanded(
              child: SubjectCard(
                subject: _toView(subjects[i + 1]),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.courseDetail,
                  arguments: {
                    'subjectId': subjects[i + 1].id,
                    'gradeId': gradeId,
                  },
                ),
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
      if (i + 2 < subjects.length) rows.add(const SizedBox(height: 13));
    }
    return Column(children: rows);
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({
    required this.label,
    this.leading,
    this.trailing,
    this.filled = false,
  });

  final String label;
  final IconData? leading;
  final IconData? trailing;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.bodyText;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: filled ? AppColors.navy : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: filled
            ? null
            : Border.all(color: const Color(0xFFE7EAF0), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            Icon(leading, size: 15, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: AppTextStyles.chip.copyWith(
                fontSize: 13,
                color: fg,
                fontWeight: filled ? FontWeight.w700 : FontWeight.w600,
              )),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Icon(trailing, size: 15, color: fg),
          ],
        ],
      ),
    );
  }
}

/// Navy "Complete Package" promo card with strikethrough pricing, bound to the
/// grade's FULL_CLASS product.
class _BundleHeroCard extends StatelessWidget {
  const _BundleHeroCard({
    required this.title,
    required this.meta,
    required this.price,
    required this.onTap,
  });

  final String title;
  final String meta;
  final ProductPrice? price;
  final VoidCallback onTap;

  int? get _savePct {
    final p = price;
    if (p == null || p.compareAtCents == null || p.compareAtCents! <= 0) {
      return null;
    }
    final pct = (1 - (p.amountCents / p.compareAtCents!)) * 100;
    final rounded = pct.round();
    return rounded > 0 ? rounded : null;
  }

  @override
  Widget build(BuildContext context) {
    final save = _savePct;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: AppGradients.heroCard,
          borderRadius: BorderRadius.circular(AppRadius.hero),
          boxShadow: AppShadows.hero,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: _orb(150, 0.05),
            ),
            Positioned(
              right: 18,
              bottom: -40,
              child: _orb(110, 0.04),
            ),
            if (save != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.signalRed,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.signalRed.withValues(alpha: 0.7),
                        blurRadius: 14,
                        spreadRadius: -4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text('SAVE $save%',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('COMPLETE PACKAGE',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      color: AppColors.onNavyAccent,
                    )),
                const SizedBox(height: 9),
                Text(title,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: -0.4,
                      height: 1.2,
                    )),
                const SizedBox(height: 8),
                Text(meta,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontSize: 13,
                      color: AppColors.onNavySubtle,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price?.displayPrice ?? '—',
                            style: AppTextStyles.display.copyWith(
                              fontSize: 27,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            )),
                        if (price?.displayCompareAt != null) ...[
                          const SizedBox(width: 9),
                          Text(price!.displayCompareAt!,
                              style: AppTextStyles.bodyLg.copyWith(
                                fontSize: 14,
                                color: const Color(0xFF8FA0C8),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough,
                              )),
                        ],
                      ],
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: const Icon(Icons.north_east_rounded,
                          size: 20, color: AppColors.navy),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      );
}
