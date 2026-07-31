import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/app_page_route.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/subject.dart';
import '../../models/api/catalog.dart';
import '../../models/api/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/decorative_blobs.dart';
import '../../widgets/common/icon_tile_button.dart';
import '../../widgets/cards/subject_card.dart';
import '../../widgets/feedback/loading_indicator.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import 'home_shell.dart';

/// 09 · Home — First-time user (fresh, onboarded account, nothing purchased).
/// Bound to the catalog: the learner's grade + its first couple of subjects,
/// pulled live so the starter cards reflect real courses and prices.
class HomeFirstTimeScreen extends StatefulWidget {
  const HomeFirstTimeScreen({super.key});

  @override
  State<HomeFirstTimeScreen> createState() => _HomeFirstTimeScreenState();
}

class _HomeFirstTimeScreenState extends State<HomeFirstTimeScreen> {
  bool _loading = true;
  String? _gradeId;
  String _gradeLabel = '';
  final List<SubjectModel> _picks = <SubjectModel>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    _gradeId = context.read<AuthProvider>().user?.profile?.gradeId;
    if (_gradeId == null) {
      setState(() => _loading = false);
      return;
    }
    final CatalogProvider catalog = context.read<CatalogProvider>();
    final Grade? grade = await catalog.loadGrade(_gradeId!);
    if (!mounted) return;
    if (grade == null) {
      setState(() => _loading = false);
      return;
    }
    _gradeLabel = '${grade.name} · ${grade.board}';
    final List<SubjectModel> firstTwo = grade.subjects.take(2).toList();
    // Load each pick's detail for real product pricing.
    final List<SubjectModel> detailed = <SubjectModel>[];
    for (final SubjectModel s in firstTwo) {
      final SubjectModel? full = await catalog.loadSubject(s.id);
      detailed.add(full ?? s);
    }
    if (!mounted) return;
    setState(() {
      _picks
        ..clear()
        ..addAll(detailed);
      _loading = false;
    });
  }

  void _openShell(int index) {
    Navigator.pushReplacement(
      context,
      AppPageRoute.fade(HomeShell(initialIndex: index)),
    );
  }

  void _openSubject(SubjectModel s) => Navigator.pushNamed(
        context,
        AppRoutes.courseDetail,
        arguments: {'subjectId': s.id, 'gradeId': _gradeId},
      );

  Subject _toView(SubjectModel s) {
    int priceFrom = 0;
    for (final Product p in s.products) {
      final price = p.priceFor();
      if (price != null) {
        final int rupees = (price.amountCents / 100).round();
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

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return AppScaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: GtecBottomNav(
        currentIndex: 0,
        onTap: (int i) {
          if (i != 0) _openShell(i);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
        children: <Widget>[
          Row(
            children: <Widget>[
              HatchTile(
                  width: 46,
                  height: 46,
                  label: auth.initials,
                  radius: 14,
                  band: 7),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Welcome to G-TEC',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.5,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        )),
                    const SizedBox(height: 2),
                    Text('Hi, ${auth.displayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.titleSm.copyWith(letterSpacing: -0.3)),
                  ],
                ),
              ),
              IconTileButton(
                icon: Icons.notifications_none_rounded,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SetupHero(
            gradeLabel: _gradeLabel,
            onExplore: () => _openShell(1),
          ),
          const SizedBox(height: 14),
          _FreeSampleCard(
            onTap: () {
              if (_picks.isNotEmpty) {
                _openSubject(_picks.first);
              } else {
                _openShell(1);
              }
            },
          ),
          const SizedBox(height: 26),
          Text('Start with a subject', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingIndicator(size: 26),
            )
          else if (_picks.isEmpty)
            Text('Explore the store to find your subjects.',
                style: AppTextStyles.body.copyWith(color: AppColors.muted))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < _picks.length; i++) ...<Widget>[
                  Expanded(
                    child: SubjectCard(
                      subject: _toView(_picks[i]),
                      onTap: () => _openSubject(_picks[i]),
                    ),
                  ),
                  if (i != _picks.length - 1) const SizedBox(width: 13),
                ],
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
