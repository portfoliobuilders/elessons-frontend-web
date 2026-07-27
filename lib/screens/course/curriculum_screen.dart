import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../core/utils/subject_image_helper.dart';
import '../../models/api/catalog.dart';
import '../../models/api/learning.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/progress_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/progress_track.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

String _mono(String value) {
  final String letters = value.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return 'GT';
  return letters
      .substring(0, letters.length >= 3 ? 3 : letters.length)
      .toUpperCase();
}

/// 20 · Course Curriculum — bound to GET /subjects/:id (chapters) with each
/// chapter's lessons lazily fetched from GET /chapters/:id on expand. Overall
/// progress comes from GET /me/learnings and the "now playing" lesson from
/// GET /me/continue. Layout and components are unchanged from the design.
class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  bool _argsRead = false;
  String? _subjectId;
  String? _chapterId; // when entered from a chapter search result

  bool _loading = true;
  String? _error;

  SubjectModel? _subject;
  LearningCourse? _course;
  ContinueLesson? _continue;

  final Set<String> _expanded = <String>{};
  final Map<String, List<LessonSummary>> _lessons = <String, List<LessonSummary>>{};
  final Set<String> _chapterLoading = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final Object? raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      _subjectId = raw['subjectId'] as String?;
      _chapterId = raw['chapterId'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final CatalogProvider catalog = context.read<CatalogProvider>();
    final ProgressProvider progress = context.read<ProgressProvider>();

    String? focusChapter = _chapterId;

    // Resolve the subject id when we only arrived with a chapter.
    if (_subjectId == null && _chapterId != null) {
      final Chapter? ch = await catalog.loadChapter(_chapterId!);
      if (ch != null) {
        _subjectId = ch.subjectId;
        _lessons[ch.id] = ch.lessons;
      }
    }

    if (_subjectId == null) {
      setState(() {
        _loading = false;
        _error = catalog.error ?? 'This course could not be opened.';
      });
      return;
    }

    final SubjectModel? subject = await catalog.loadSubject(_subjectId!);
    if (subject == null) {
      setState(() {
        _loading = false;
        _error = catalog.error ?? 'This course could not be loaded.';
      });
      return;
    }

    // Progress + continue lesson (best-effort; failures are non-fatal).
    await progress.loadLearnings();
    LearningCourse? course;
    for (final LearningCourse c in progress.courses) {
      if (c.subjectId == subject.id) {
        course = c;
        break;
      }
    }

    // Decide which chapter to open first.
    focusChapter ??= subject.chapters.isNotEmpty ? subject.chapters.first.id : null;

    setState(() {
      _subject = subject;
      _course = course;
      _continue = progress.continueLesson;
      _loading = false;
      if (focusChapter != null) _expanded.add(focusChapter);
    });

    if (focusChapter != null && !_lessons.containsKey(focusChapter)) {
      _loadChapter(focusChapter);
    }
  }

  Future<void> _loadChapter(String chapterId) async {
    if (_lessons.containsKey(chapterId) || _chapterLoading.contains(chapterId)) {
      return;
    }
    setState(() => _chapterLoading.add(chapterId));
    final Chapter? ch = await context.read<CatalogProvider>().loadChapter(chapterId);
    if (!mounted) return;
    setState(() {
      _chapterLoading.remove(chapterId);
      _lessons[chapterId] = ch?.lessons ?? const <LessonSummary>[];
    });
  }

  void _toggle(String chapterId) {
    setState(() {
      if (_expanded.contains(chapterId)) {
        _expanded.remove(chapterId);
      } else {
        _expanded.add(chapterId);
      }
    });
    if (_expanded.contains(chapterId)) _loadChapter(chapterId);
  }

  void _openLesson(String lessonId, String title) => Navigator.pushNamed(
        context,
        AppRoutes.videoPlayer,
        arguments: {'lessonId': lessonId, 'title': title},
      );

  // Bottom CTA target: prefer the global continue lesson when it belongs to
  // this subject, else the first lesson of the first loaded chapter.
  _CtaTarget? get _ctaTarget {
    final ContinueLesson? c = _continue;
    if (c != null && _subject != null && c.subject == _subject!.name) {
      return _CtaTarget(c.lessonId, c.title, resume: true);
    }
    final SubjectModel? s = _subject;
    if (s != null) {
      for (final Chapter ch in s.chapters) {
        final List<LessonSummary>? ls = _lessons[ch.id];
        if (ls != null && ls.isNotEmpty) {
          return _CtaTarget(ls.first.id, ls.first.title, resume: false);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _OutlineIcon(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.maybePop(context)),
                Text('Course Content',
                    style: AppTextStyles.heading.copyWith(fontSize: 15)),
                _OutlineIcon(icon: Icons.bookmark_border_rounded, onTap: () {}),
              ],
            ),
          ),
          Expanded(child: _content()),
          if (!_loading && _error == null && _subject != null) _bottomBar(),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const LoadingIndicator(message: 'Loading course…');
    }
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn\'t load course',
        message: _error!,
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    final SubjectModel s = _subject!;
    final List<Chapter> chapters = s.chapters;

    final int totalLessons = _course?.totalLessons != null && _course!.totalLessons > 0
        ? _course!.totalLessons
        : chapters.fold<int>(0, (int sum, Chapter c) => sum + c.lessonCount);
    final int done = _course?.completedLessons ?? 0;
    final int percent = _course?.percent ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
      children: <Widget>[
        Row(
          children: <Widget>[
            SubjectImageHelper.buildSubjectThumbnail(
              name: s.name,
              code: s.code ?? _mono(s.name),
              width: 96,
              height: 64,
              radius: 16,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.name,
                      style: AppTextStyles.titleSm
                          .copyWith(fontSize: 18, height: 1.2)),
                  const SizedBox(height: 3),
                  Text(
                    '${chapters.length} module${chapters.length == 1 ? '' : 's'} · $totalLessons lesson${totalLessons == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('$done of $totalLessons lessons',
                      style: AppTextStyles.cardTitle),
                  Text('$percent%',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy)),
                ],
              ),
              const SizedBox(height: 10),
              ProgressTrack(
                value: (percent.clamp(0, 100)) / 100.0,
                height: 7,
                trackColor: const Color(0xFFE4E8EF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (chapters.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No lessons yet',
              message: 'Content for this course is being prepared.',
            ),
          )
        else
          for (int i = 0; i < chapters.length; i++) ...<Widget>[
            _module(chapters[i], i),
            if (i != chapters.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _module(Chapter chapter, int index) {
    final bool expanded = _expanded.contains(chapter.id);
    final String title = 'Module ${index + 1} · ${chapter.name}';
    final String subtitle =
        '${chapter.lessonCount} lesson${chapter.lessonCount == 1 ? '' : 's'}';

    if (!expanded) {
      return GestureDetector(
        onTap: () => _toggle(chapter.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderSoft, width: 1.5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: AppTextStyles.cardTitle
                            .copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.muted),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E6F0), width: 1.5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => _toggle(chapter.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: AppColors.surfaceSoft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title,
                              style: AppTextStyles.cardTitle
                                  .copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy)),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_up_rounded,
                        size: 18, color: AppColors.navy),
                  ],
                ),
              ),
            ),
            _moduleBody(chapter),
          ],
        ),
      ),
    );
  }

  Widget _moduleBody(Chapter chapter) {
    if (_chapterLoading.contains(chapter.id)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: LoadingIndicator(size: 24),
      );
    }
    final List<LessonSummary> lessons =
        _lessons[chapter.id] ?? const <LessonSummary>[];
    if (lessons.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEEF1F6)))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        alignment: Alignment.centerLeft,
        child: const Text('No lessons in this module yet.',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.muted)),
      );
    }

    final String? currentId = _continue?.lessonId;
    return Column(
      children: <Widget>[
        for (int i = 0; i < lessons.length; i++)
          if (lessons[i].id == currentId)
            _CurrentLesson(
              title: lessons[i].title,
              meta: 'Now playing · ${lessons[i].durationLabel}',
              badge: '${i + 1}',
              onTap: () => _openLesson(lessons[i].id, lessons[i].title),
            )
          else
            _LessonRow(
              index: '${i + 1}',
              title: lessons[i].title,
              meta: lessons[i].isFreePreview
                  ? 'Free preview · ${lessons[i].durationLabel}'
                  : lessons[i].durationLabel,
              onTap: () => _openLesson(lessons[i].id, lessons[i].title),
            ),
      ],
    );
  }

  Widget _bottomBar() {
    final _CtaTarget? target = _ctaTarget;
    final String label = target == null
        ? 'Start learning'
        : (target.resume ? 'Continue · ${target.title}' : 'Start · ${target.title}');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 13, 20, 22 + MediaQuery.of(context).padding.bottom),
      child: GestureDetector(
        onTap: () {
          final _CtaTarget? t = _ctaTarget;
          if (t != null) {
            _openLesson(t.lessonId, t.title);
          } else if (_subject != null && _subject!.chapters.isNotEmpty) {
            final String first = _subject!.chapters.first.id;
            if (!_expanded.contains(first)) _toggle(first);
          }
        },
        child: Container(
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(AppRadius.input),
            boxShadow: AppShadows.primaryButton,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.play_arrow_rounded,
                  size: 18, color: Colors.white),
              const SizedBox(width: 9),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaTarget {
  const _CtaTarget(this.lessonId, this.title, {required this.resume});
  final String lessonId;
  final String title;
  final bool resume;
}

class _CurrentLesson extends StatelessWidget {
  const _CurrentLesson({
    required this.title,
    required this.meta,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String meta;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppColors.navy,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 15, color: AppColors.navy),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 1),
                  Text(meta,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onNavyAccent)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Neutral lesson row (order + title + duration) → opens the player.
class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.index,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final String index;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEEF1F6)))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: <Widget>[
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Text(index,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB0B7C3))),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  const SizedBox(height: 1),
                  Text(meta,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_arrow_rounded,
                size: 16, color: AppColors.navy),
          ],
        ),
      ),
    );
  }
}

class _OutlineIcon extends StatelessWidget {
  const _OutlineIcon({required this.icon, required this.onTap});

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
