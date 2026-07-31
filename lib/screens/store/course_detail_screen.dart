import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/trailer_artwork.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/catalog.dart';
import '../../models/api/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';

import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

enum _Plan { recorded, live }

enum _Catalogue { full, subject, module }

/// 14 · Course Detail — Recorded vs Live plan, bound to live catalog products.
///
/// Args: {gradeId?, subjectId?, productId?}. Resolves the grade's products
/// (FULL_CLASS / SUBJECT / MODULE, RECORDED / LIVE_AND_RECORDED) and wires every
/// add-to-cart to a real product id.
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  _Plan _plan = _Plan.recorded;
  _Catalogue _cat = _Catalogue.full;

  String? _gradeId;
  String? _subjectId;
  bool _argsRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _gradeId = args['gradeId'] as String?;
      _subjectId = args['subjectId'] as String?;
    }
    _gradeId ??= context.read<AuthProvider>().user?.profile?.gradeId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final catalog = context.read<CatalogProvider>();
    if (_gradeId != null && catalog.gradeById(_gradeId!) == null) {
      await catalog.loadGrade(_gradeId!);
    }
    if (!mounted) return;
    // Ensure the focus subject (for the By Module view) is loaded.
    final gid = _gradeId;
    final grade = gid == null ? null : catalog.gradeById(gid);
    final focus = _subjectId ??
        (grade != null && grade.subjects.isNotEmpty
            ? grade.subjects.first.id
            : null);
    if (focus != null && catalog.subjectById(focus) == null) {
      await catalog.loadSubject(focus);
    }
  }

  void _snack(String m,
      {VoidCallback? onAction, String actionLabel = 'GO TO CART'}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.signalRed,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed:
              onAction ?? () => Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ));
  }

  Future<void> _add(Product? product) async {
    if (product == null) {
      _snack("This option isn't available yet.",
          actionLabel: 'DISMISS', onAction: () {});
      return;
    }
    final cart = context.read<CartProvider>();
    final err = await cart.add(product.id);
    if (!mounted) return;
    if (err != null) {
      _snack(
        err,
        actionLabel: 'GO TO CART',
        onAction: () => Navigator.pushNamed(context, AppRoutes.cart),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  Product? _fullClass(Grade? g, {required bool live}) {
    if (g == null) return null;
    for (final p in g.products) {
      if (p.type == 'FULL_CLASS' && (live ? p.isLive : p.isRecorded)) return p;
    }
    // Fall back to any FULL_CLASS product if the exact format isn't present.
    for (final p in g.products) {
      if (p.type == 'FULL_CLASS') return p;
    }
    return null;
  }

  Product? _subjectProduct(Grade? g, String subjectId) {
    if (g == null) return null;
    for (final s in g.subjects) {
      if (s.id == subjectId) {
        for (final p in s.products) {
          if (p.type == 'SUBJECT') return p;
        }
      }
    }
    for (final p in g.products) {
      if (p.type == 'SUBJECT' && p.subjectId == subjectId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final region = auth.user?.profile?.region ?? 'IN';
    final currency = auth.user?.profile?.currency ?? 'INR';

    final grade = _gradeId == null ? null : catalog.gradeById(_gradeId!);
    final loading = grade == null && catalog.status.isLoading;
    final error = grade == null && catalog.status.isError;

    final gradeName = grade?.name ?? 'Class 10';
    final board = grade?.board ?? 'CBSE';
    final subjects = grade?.subjects ?? const <SubjectModel>[];
    final totalLessons = subjects.fold<int>(0, (sum, s) => sum + s.lessonCount);

    final fullRecorded = _fullClass(grade, live: false);
    final fullLive = _fullClass(grade, live: true);
    final selectedFull = _plan == _Plan.recorded ? fullRecorded : fullLive;
    final selPrice = selectedFull?.priceFor(region: region, currency: currency);
    final recPrice = fullRecorded?.priceFor(region: region, currency: currency);
    final livePrice = fullLive?.priceFor(region: region, currency: currency);
    final accessMonths =
        selectedFull != null ? (selectedFull.accessDays / 30).round() : 12;

    final focus =
        _subjectId ?? (subjects.isNotEmpty ? subjects.first.id : null);
    final focusSubject = focus != null ? catalog.subjectById(focus) : null;

    String? trailerId;
    if (focusSubject != null && focusSubject.chapters.isNotEmpty) {
      for (final chap in focusSubject.chapters) {
        if (chap.lessons.isNotEmpty) {
          trailerId = chap.lessons.first.id;
          break;
        }
      }
    }
    if (trailerId == null) {
      for (final s in subjects) {
        final subDetail = catalog.subjectById(s.id);
        if (subDetail != null && subDetail.chapters.isNotEmpty) {
          for (final chap in subDetail.chapters) {
            if (chap.lessons.isNotEmpty) {
              trailerId = chap.lessons.first.id;
              break;
            }
          }
        }
        if (trailerId != null) break;
      }
    }

    return AppScaffold(
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // nav bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _NavIcon(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.maybePop(context)),
                Text('Course Detail',
                    style: AppTextStyles.heading.copyWith(fontSize: 15)),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFE7EAF0), width: 1.5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Badge(
                            isLabelVisible:
                                context.watch<CartProvider>().count > 0,
                            label:
                                Text('${context.watch<CartProvider>().count}'),
                            backgroundColor: AppColors.signalRed,
                            child: const Icon(Icons.shopping_cart_outlined,
                                size: 20, color: AppColors.ink),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    _NavIcon(icon: Icons.bookmark_border_rounded, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const LoadingIndicator()
                : error
                    ? EmptyState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Something went wrong',
                        message: catalog.error ?? 'Could not load this course.',
                        actionLabel: 'Retry',
                        onAction: _load,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
                        children: <Widget>[
                          _Hero(
                            targetId: trailerId,
                            isHistory: focusSubject?.name.toLowerCase().contains('history') ?? false,
                          ),
                          const SizedBox(height: 16),
                          Text('$gradeName — $board',
                              style: AppTextStyles.headlineHero.copyWith(
                                  fontSize: 21,
                                  height: 1.2,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Text(
                              'Aligned to the latest NCERT syllabus · ${subjects.length} subjects',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.slate)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              if (totalLessons > 0)
                                _StatChip('$totalLessons Lessons'),
                              const _StatChip('PDF Notes & PYQs'),
                              _StatChip('$accessMonths-month access'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('CHOOSE YOUR PLAN',
                              style: AppTextStyles.overline.copyWith(
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  color: AppColors.muted)),
                          const SizedBox(height: 11),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: _PlanCard(
                                  icon: Icons.play_circle_outline_rounded,
                                  title: 'Recorded',
                                  blurb:
                                      'Self-paced video lessons, notes & mock tests.',
                                  price: recPrice?.displayPrice ?? '—',
                                  selected: _plan == _Plan.recorded,
                                  onTap: () =>
                                      setState(() => _plan = _Plan.recorded),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: _PlanCard(
                                  icon: Icons.podcasts_rounded,
                                  title: 'Live + Recorded',
                                  blurb:
                                      'Weekly live mentor classes + all recordings.',
                                  price: livePrice?.displayPrice ?? '—',
                                  selected: _plan == _Plan.live,
                                  badge: 'MENTOR-LED',
                                  onTap: () =>
                                      setState(() => _plan = _Plan.live),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _CatalogueTabs(
                            selected: _cat,
                            onChanged: (_Catalogue c) {
                              if (c == _Catalogue.module) {
                                Navigator.pushNamed(
                                    context, AppRoutes.byModule);
                              } else {
                                setState(() => _cat = c);
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOut,
                            transitionBuilder:
                                (Widget child, Animation<double> a) {
                              return FadeTransition(
                                opacity: a,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.04),
                                    end: Offset.zero,
                                  ).animate(a),
                                  child: child,
                                ),
                              );
                            },
                            child: _catalogueView(grade, subjects, totalLessons,
                                region, currency),
                          ),
                        ],
                      ),
          ),
          if (!loading && !error)
            _StickyCta(
              label: _plan == _Plan.recorded ? 'Recorded' : 'Live + Recorded',
              price: selPrice?.displayPrice ?? '—',
              strike: selPrice?.displayCompareAt,
              onAdd: () => _add(selectedFull),
            ),
        ],
      ),
    );
  }

  Widget _catalogueView(Grade? grade, List<SubjectModel> subjects,
      int totalLessons, String region, String currency) {
    switch (_cat) {
      case _Catalogue.full:
        return _FullClassView(
          key: const ValueKey<String>('full'),
          subjectCount: subjects.length,
          totalLessons: totalLessons,
        );
      case _Catalogue.subject:
        final rows = subjects
            .map((s) => _SubjectRowData(
                  subject: s,
                  product: _subjectProduct(grade, s.id),
                  region: region,
                  currency: currency,
                ))
            .toList();
        return _BySubjectView(
          key: const ValueKey<String>('subject'),
          rows: rows,
          onAdd: _add,
        );
      case _Catalogue.module:
        return const SizedBox.shrink();
    }
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.onTap});

  final IconData icon;
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
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.targetId, this.isHistory = false});

  final String? targetId;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (targetId == null || targetId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course trailer is currently unavailable.')),
          );
          return;
        }
        Navigator.pushNamed(
          context,
          AppRoutes.videoPlayer,
          arguments: {
            'lessonId': targetId,
            'title': 'Course Trailer',
          },
        );
      },
      child: Container(
        height: 178,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.hero,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: <Widget>[
              // Course Trailer Artwork Image
              Positioned.fill(
                child: isHistory
                    ? Image.asset(
                        'assets/images/history_course_trailer.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const HatchTile(
                          height: 178,
                          radius: 20,
                          band: 11,
                        ),
                      )
                    : Image(
                        image: TrailerArtwork.imageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/geography_course_trailer.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const HatchTile(
                                height: 178,
                                radius: 20,
                                band: 11,
                              );
                            },
                          );
                        },
                      ),
              ),
              // Dark gradient overlay for text legibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const <double>[0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Header tag
              Positioned(
                top: 14,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Text('COURSE TRAILER',
                      style: AppTextStyles.mono.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              // Play Button
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.signalRed,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.signalRed.withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 32, color: Colors.white),
                ),
              ),
              // Rating Badge
              Positioned(
                bottom: 13,
                right: 13,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xD10A0E17),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFFFC53D)),
                      SizedBox(width: 5),
                      Text('4.9',
                          style: TextStyle(
                              fontSize: 12,
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
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText)),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.icon,
    required this.title,
    required this.blurb,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String blurb;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F9FF) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.navy : const Color(0xFFE6EAF2),
            width: selected ? 1.8 : 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (badge != null)
              Positioned(
                top: -23,
                right: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.signalRed,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(badge!,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: Colors.white)),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7ECF6),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, size: 20, color: AppColors.navy),
                    ),
                    _RadioDot(selected: selected),
                  ],
                ),
                const SizedBox(height: 11),
                Text(title,
                    style: AppTextStyles.cardTitle
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(blurb,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: AppColors.slate)),
                const SizedBox(height: 10),
                Text(price,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.navy,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD6DBE5), width: 2),
      ),
    );
  }
}

class _CatalogueTabs extends StatelessWidget {
  const _CatalogueTabs({required this.selected, required this.onChanged});

  final _Catalogue selected;
  final ValueChanged<_Catalogue> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>[
      'Full Class',
      'By Subject',
      'By Module'
    ];
    final int index = _Catalogue.values.indexOf(selected);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double segWidth = (constraints.maxWidth - 8) / 3;
        return Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.trackBg,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: segWidth * index,
                top: 0,
                bottom: 0,
                width: segWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List<Widget>.generate(3, (int i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(_Catalogue.values[i]),
                      child: Center(
                        child: Text(labels[i],
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FullClassView extends StatelessWidget {
  const _FullClassView({
    super.key,
    required this.subjectCount,
    required this.totalLessons,
  });

  final int subjectCount;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final features = <String>[
      totalLessons > 0
          ? 'All $subjectCount subjects · $totalLessons+ video lessons'
          : 'All $subjectCount subjects',
      'Chapter-wise PDF notes & PYQs',
      'Full-length mock tests',
      'Live doubt-solving support',
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E6F0), width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.surfaceSoft, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text('Everything included',
                    style: AppTextStyles.sectionTitle
                        .copyWith(fontSize: 16, letterSpacing: -0.3)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7ECF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('BEST VALUE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...features.map((String f) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 21,
                      height: 21,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7ECF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 13, color: AppColors.navy),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(f,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bodyText)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SubjectRowData {
  const _SubjectRowData({
    required this.subject,
    required this.product,
    required this.region,
    required this.currency,
  });
  final SubjectModel subject;
  final Product? product;
  final String region;
  final String currency;
}

class _BySubjectView extends StatelessWidget {
  const _BySubjectView({
    super.key,
    required this.rows,
    required this.onAdd,
  });

  final List<_SubjectRowData> rows;
  final ValueChanged<Product?> onAdd;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      final r = rows[i];
      final price = r.product
              ?.priceFor(region: r.region, currency: r.currency)
              ?.displayPrice ??
          '—';
      children.add(_SubjectRow(
        code: r.subject.monogram,
        name: r.subject.name,
        meta:
            '${r.subject.chapterCount} modules · ${r.subject.lessonCount} lessons',
        price: price,
        onAdd: () => onAdd(r.product),
      ));
      if (i != rows.length - 1) children.add(const SizedBox(height: 11));
    }
    return Column(children: children);
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.code,
    required this.name,
    required this.meta,
    required this.price,
    required this.onAdd,
  });

  final String code;
  final String name;
  final String meta;
  final String price;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSoft, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          HatchTile(width: 46, height: 46, radius: 12, label: code),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: AppTextStyles.cardTitle),
                const SizedBox(height: 1),
                Text(meta,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(price,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              const SizedBox(height: 5),
              _AddPill(onTap: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPill extends StatelessWidget {
  const _AddPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.navy, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Text('Add',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy)),
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  const _StickyCta({
    required this.label,
    required this.price,
    required this.strike,
    required this.onAdd,
  });

  final String label;
  final String price;
  final String? strike;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 13, 20, 22 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.muted)),
              const SizedBox(height: 3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(price,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  if (strike != null) ...[
                    const SizedBox(width: 6),
                    Text(strike!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.iconMuted,
                            decoration: TextDecoration.lineThrough)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  boxShadow: AppShadows.primaryButton,
                ),
                child: const Text('Add to Cart',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
