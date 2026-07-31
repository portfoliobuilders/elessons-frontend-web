import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/responsive_grid.dart';
import '../../models/subject.dart';
import '../../models/api/catalog.dart';
import '../../models/api/learning.dart';
import '../../models/api/live.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/live_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/decorative_blobs.dart';
import '../../widgets/common/icon_tile_button.dart';
import '../../widgets/common/live_now_banner.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/cards/subject_card.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';
import '../../widgets/inputs/subject_chip.dart';

/// 10 · Home — Returning user. Rendered as the first tab of [HomeShell].
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _chip = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gradeId = context.read<AuthProvider>().user?.profile?.gradeId;
      context.read<HomeProvider>().refresh(gradeId: gradeId);
      context.read<LiveProvider>().loadUpcoming();
    });
  }

  /// Maps a backend subject (enriched with chapters + products) to the card
  /// view-model, deriving "from ₹…" from the cheapest active product.
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

  String _continueLabel(ContinueLesson c) {
    final pct = (c.progress * 100).round();
    final dur = c.durationSeconds ?? 0;
    final leftSec = (dur - c.watchedSeconds).clamp(0, dur);
    final leftMin = (leftSec / 60).round();
    return dur > 0 ? '$pct% · $leftMin min left' : '$pct%';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final home = context.watch<HomeProvider>();
    final live = context.watch<LiveProvider>();
    final gradeId = auth.user?.profile?.gradeId;

    final subjects = home.subjects;
    final chips = <String>['All', ...subjects.map((s) => s.name)];
    if (_chip >= chips.length) _chip = 0;
    final selectedName = _chip > 0 ? chips[_chip] : null;
    final filtered = selectedName == null
        ? subjects
        : subjects.where((s) => s.name == selectedName).toList();
    final recommended = filtered.take(2).toList();

    LiveClass? lc;
    for (final c in live.classes) {
      if (c.isLive) {
        lc = c;
        break;
      }
    }
    final cl = home.continueLesson;
    final loadingContent = home.status.isLoading && subjects.isEmpty;
    final errorContent = home.status.isError && subjects.isEmpty;

    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: () => home.refresh(gradeId: gradeId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
        children: [
          _GreetingHeader(
            eyebrow: AppStrings.welcomeBack,
            name: auth.displayName,
            initials: auth.initials,
            onSearch: () => Navigator.pushNamed(context, AppRoutes.search),
            onBell: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          const SizedBox(height: 20),
          if (cl != null) ...[
            _ContinueLearningCard(
              title: cl.title,
              subtitle: '${cl.subject} · ${cl.chapter}',
              progress: cl.progress,
              progressLabel: _continueLabel(cl),
              onResume: () => Navigator.pushNamed(
                context,
                AppRoutes.videoPlayer,
                arguments: {'lessonId': cl.lessonId},
              ),
            ),
            const SizedBox(height: 22),
          ] else if (home.loaded && subjects.isNotEmpty) ...[
            _SetupHero(
              gradeLabel: home.grade != null
                  ? '${home.grade!.name} · ${home.grade!.board}'
                  : '',
              onExplore: () => Navigator.pushNamed(context, AppRoutes.store),
            ),
            const SizedBox(height: 14),
            _FreeSampleCard(
              onTap: () {
                if (recommended.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.subjectDetail,
                    arguments: {
                      'subjectId': recommended.first.id,
                      'gradeId': gradeId,
                    },
                  );
                } else {
                  Navigator.pushNamed(context, AppRoutes.store);
                }
              },
            ),
            const SizedBox(height: 26),
          ],
          if (chips.length > 1) ...[
            SizedBox(
              height: 34,
              child: SubjectChipBar(
                labels: chips,
                selectedIndex: _chip,
                onSelected: (i) => setState(() => _chip = i),
              ),
            ),
            const SizedBox(height: 20),
          ],
          LiveNowBanner(
            title: lc?.title ?? 'Trigonometry Doubt Class',
            subtitle: lc != null
                ? '${lc.mentorName} · ${lc.watchingCount} watching now'
                : 'R. Menon · 318 watching now',
            onTap: () => Navigator.pushNamed(
              context,
              lc != null ? AppRoutes.liveRoom : AppRoutes.liveClasses,
              arguments: lc != null
                  ? {
                      'classId': lc.id,
                      'title': lc.title,
                      'mentorName': lc.mentorName,
                      'subject': lc.subject,
                    }
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: cl == null ? 'Start with a subject' : AppStrings.recommendedForYou,
            action: AppStrings.seeAll,
            onAction: () => Navigator.pushNamed(context, AppRoutes.store),
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
              message: home.error ?? 'Could not load your classes.',
              actionLabel: 'Retry',
              onAction: () => home.refresh(gradeId: gradeId),
            )
          else if (recommended.isEmpty)
            const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No subjects yet',
              message: 'Your class content will appear here soon.',
            )
          else if (context.isDesktop || context.isTablet)
            ResponsiveGrid(
              itemCount: filtered.length,
              phoneCols: 1,
              tabletCols: 2,
              desktopCols: 3,
              wideDesktopCols: 4,
              childAspectRatio: 1.55,
              itemBuilder: (context, i) => SubjectCard(
                subject: _toView(filtered[i]),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.subjectDetail,
                  arguments: {
                    'subjectId': filtered[i].id,
                    'gradeId': gradeId,
                  },
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < recommended.length; i++) ...[
                  Expanded(
                    child: SubjectCard(
                      subject: _toView(recommended[i]),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.subjectDetail,
                        arguments: {
                          'subjectId': recommended[i].id,
                          'gradeId': gradeId,
                        },
                      ),
                    ),
                  ),
                  if (i != recommended.length - 1) const SizedBox(width: 13),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

/// Avatar + greeting + trailing action tiles.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.eyebrow,
    required this.name,
    required this.initials,
    this.onSearch,
    this.onBell,
  });

  final String eyebrow;
  final String name;
  final String initials;
  final VoidCallback? onSearch;
  final VoidCallback? onBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HatchTile(width: 46, height: 46, label: initials, radius: 14, band: 7),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(eyebrow,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.5,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  )),
              const SizedBox(height: 2),
              Text(name,
                  style: AppTextStyles.titleSm.copyWith(letterSpacing: -0.3)),
            ],
          ),
        ),
        if (onSearch != null) ...[
          IconTileButton(icon: Icons.search, onTap: onSearch),
          const SizedBox(width: 9),
        ],
        if (onBell != null)
          IconTileButton(
            icon: Icons.notifications_none_rounded,
            showDot: true,
            onTap: onBell,
          ),
      ],
    );
  }
}

/// Navy "Continue learning" hero card with progress + Resume button.
class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressLabel,
    required this.onResume,
  });
  final String title;
  final String subtitle;
  final double progress;
  final String progressLabel;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: AppShadows.hero,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(right: -30, top: -30, child: DecorBlob(size: 140)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.continueLearning.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: AppColors.onNavyAccent,
                  )),
              const SizedBox(height: 9),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 19,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  )),
              const SizedBox(height: 5),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 12.5,
                    color: AppColors.onNavySubtle,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(progressLabel,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onNavySubtle,
                      )),
                  GestureDetector(
                    onTap: onResume,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              size: 16, color: AppColors.navy),
                          const SizedBox(width: 7),
                          Text(AppStrings.resume,
                              style: AppTextStyles.buttonSm.copyWith(
                                  color: AppColors.navy, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupHero extends StatelessWidget {
  const _SetupHero({required this.gradeLabel, required this.onExplore});
  final String gradeLabel;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final String heading =
        gradeLabel.isEmpty ? 'Your learning\nstarts here' : '$gradeLabel\nstarts here';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: AppShadows.hero,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          const Positioned(right: -30, top: -34, child: DecorBlob(size: 150)),
          const Positioned(
              right: 24, bottom: -46, child: DecorBlob(size: 120, opacity: 0.04)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('YOUR PLAN IS READY',
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: AppColors.onNavyAccent,
                  )),
              const SizedBox(height: 10),
              Text(heading,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: -0.4,
                    height: 1.2,
                  )),
              const SizedBox(height: 9),
              Text(
                'Begin with the full-year program, or add subjects one at a time — whatever suits you.',
                style: AppTextStyles.bodyLg.copyWith(
                  fontSize: 13,
                  color: AppColors.onNavySubtle,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onExplore,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Explore the Store',
                          style: AppTextStyles.buttonSm.copyWith(
                              color: AppColors.navy, fontSize: 14)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 17, color: AppColors.navy),
                    ],
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

class _FreeSampleCard extends StatelessWidget {
  const _FreeSampleCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.redBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: const Color(0xFFF6D7DA), width: 1.5),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.signalRed,
                borderRadius: BorderRadius.circular(14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.signalRed.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Watch a free sample class',
                      style: AppTextStyles.cardTitle),
                  const SizedBox(height: 2),
                  Text('Free preview lessons inside',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11.5,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA06A6E),
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.signalRed),
          ],
        ),
      ),
    );
  }
}
