import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/search.dart';
import '../../providers/search_provider.dart';
import '../../providers/view_status.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../home/home_shell.dart';

/// Monogram for catalog tiles — up to three letters of a name.
String _mono(String value) {
  final String letters = value.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return 'GT';
  return letters
      .substring(0, letters.length >= 3 ? 3 : letters.length)
      .toUpperCase();
}

/// 12 · Search — bound to GET /search (public, min 2 chars).
///
/// The query is debounced and dispatched to [SearchProvider]; results are
/// rendered live. With no active query the recent-search history from local
/// storage is shown. The layout, cards and bottom navigation are unchanged
/// from the source design — only the data behind them is real.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  int _filter = 0; // 0 All · 1 Subjects · 2 Lessons · 3 Tests

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<SearchProvider>().search(value);
    });
  }

  void _runNow(String value) {
    _debounce?.cancel();
    context.read<SearchProvider>().search(value);
  }

  void _applyRecent(String term) {
    _controller.text = term;
    _controller.selection =
        TextSelection.collapsed(offset: term.length);
    setState(() {});
    _runNow(term);
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    context.read<SearchProvider>().clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => HomeShellLauncher(index: index)),
        (_) => false,
      );
    }
  }

  // ── Result navigation ──
  void _openSubject(String subjectId, String name) => Navigator.pushNamed(
        context,
        AppRoutes.curriculum,
        arguments: {'subjectId': subjectId, 'subjectName': name},
      );

  void _openChapter(SearchChapter c) => Navigator.pushNamed(
        context,
        AppRoutes.curriculum,
        arguments: {'chapterId': c.id, 'subjectName': c.subjectName},
      );

  void _openLesson(SearchLesson l) => Navigator.pushNamed(
        context,
        AppRoutes.videoPlayer,
        arguments: {'lessonId': l.id, 'title': l.title},
      );

  void _openTest(SearchTest t) => Navigator.pushNamed(
        context,
        AppRoutes.testAttempt,
        arguments: {
          'assessmentId': t.id,
          'title': t.title,
          'subtitle': t.subjectName,
        },
      );

  @override
  Widget build(BuildContext context) {
    final SearchProvider provider = context.watch<SearchProvider>();

    return AppScaffold(
      safeBottom: false,
      bottomNavigationBar: GtecBottomNav(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // search field row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(color: AppColors.navy, width: 1.5),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.search_rounded,
                            size: 19, color: AppColors.navy),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            cursorColor: AppColors.navy,
                            textInputAction: TextInputAction.search,
                            style: AppTextStyles.cardTitle
                                .copyWith(color: AppColors.ink),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Search courses, notes…',
                            ),
                            onChanged: _onChanged,
                            onSubmitted: _runNow,
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: _clear,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD6DCE6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (Navigator.of(context).canPop()) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Text('Cancel',
                        style: AppTextStyles.cardTitle
                            .copyWith(color: AppColors.navy)),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(SearchProvider provider) {
    final String q = _controller.text.trim();

    if (q.length < 2) {
      return _RecentPanel(
        recent: provider.recent,
        onTap: _applyRecent,
      );
    }
    switch (provider.status) {
      case ViewStatus.loading:
        return const LoadingIndicator(message: 'Searching…');
      case ViewStatus.error:
        return EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Couldn\'t search',
          message: provider.error ?? 'Something went wrong. Please try again.',
          actionLabel: 'Retry',
          onAction: () => _runNow(_controller.text),
        );
      case ViewStatus.idle:
      case ViewStatus.success:
        final SearchResults r = provider.results;
        if (r.isEmpty) {
          return EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No results',
            message: 'No matches for “$q”. Try another term.',
          );
        }
        return _results(r);
    }
  }

  Widget _results(SearchResults r) {
    final List<String> chips = <String>[
      'All · ${r.total}',
      'Subjects',
      'Lessons',
      'Tests',
    ];

    final bool showSubjects = _filter == 0 || _filter == 1;
    final bool showChapters = _filter == 0 || _filter == 1;
    final bool showLessons = _filter == 0 || _filter == 2;
    final bool showTests = _filter == 0 || _filter == 3;

    final List<Widget> sections = <Widget>[];

    if (showSubjects && r.subjects.isNotEmpty) {
      sections.add(const _SectionLabel('Subjects'));
      for (final SearchSubject s in r.subjects) {
        sections.add(_CatalogResult(
          code: _mono(s.name),
          title: s.name,
          meta: s.gradeName == null ? 'Subject' : 'Subject · ${s.gradeName}',
          onTap: () => _openSubject(s.id, s.name),
        ));
        sections.add(const SizedBox(height: 11));
      }
    }

    if (showChapters && r.chapters.isNotEmpty) {
      sections.add(const _SectionLabel('Chapters'));
      for (final SearchChapter c in r.chapters) {
        sections.add(_CatalogResult(
          code: _mono(c.name),
          title: c.name,
          meta: c.subjectName == null ? 'Chapter' : 'Chapter · ${c.subjectName}',
          onTap: () => _openChapter(c),
        ));
        sections.add(const SizedBox(height: 11));
      }
    }

    if (showLessons && r.lessons.isNotEmpty) {
      sections.add(const _SectionLabel('Lessons'));
      for (final SearchLesson l in r.lessons) {
        final String base = <String?>[l.subjectName, l.chapterName]
            .whereType<String>()
            .join(' · ');
        sections.add(_LessonResult(
          title: l.title,
          meta: l.isFreePreview
              ? (base.isEmpty ? 'Free preview' : 'Free preview · $base')
              : (base.isEmpty ? 'Lesson' : 'Lesson · $base'),
          onWatch: () => _openLesson(l),
        ));
        sections.add(const SizedBox(height: 11));
      }
    }

    if (showTests && r.tests.isNotEmpty) {
      sections.add(const _SectionLabel('Tests'));
      for (final SearchTest t in r.tests) {
        sections.add(_TestResult(
          title: t.title,
          meta: _testMeta(t),
          onStart: () => _openTest(t),
        ));
        sections.add(const SizedBox(height: 11));
      }
    }

    if (sections.isNotEmpty && sections.last is SizedBox) {
      sections.removeLast();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      children: <Widget>[
        // filter chips
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int i) {
              final bool active = i == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = i),
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? AppColors.navy : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chips[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? Colors.white : AppColors.bodyText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            text: '${r.total} result${r.total == 1 ? '' : 's'} for ',
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate),
            children: <InlineSpan>[
              TextSpan(
                text: '“${r.query}”',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...sections,
      ],
    );
  }

  String _testMeta(SearchTest t) {
    final String kind = _typeLabel(t.type);
    if (t.subjectName == null) return kind;
    return '$kind · ${t.subjectName}';
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'MOCK_TEST':
        return 'Mock test';
      case 'PYQ':
        return 'Previous year';
      case 'ASSIGNMENT':
        return 'Assignment';
      case 'PRACTICE_QUIZ':
        return 'Practice quiz';
      default:
        return 'Test';
    }
  }
}

/// Recent-search history shown before a query is entered.
class _RecentPanel extends StatelessWidget {
  const _RecentPanel({required this.recent, required this.onTap});

  final List<String> recent;
  final void Function(String term) onTap;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'Search the catalogue',
        message:
            'Find subjects, chapters, lessons and tests. Type at least two letters to begin.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      children: <Widget>[
        Text('Recent searches',
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.ink)),
        const SizedBox(height: 12),
        ...recent.map(
          (String term) => GestureDetector(
            onTap: () => onTap(term),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.history_rounded,
                      size: 18, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(term,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.bodyText)),
                  ),
                  const Icon(Icons.north_west_rounded,
                      size: 15, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.slate,
        ),
      ),
    );
  }
}

class _ResultShell extends StatelessWidget {
  const _ResultShell(
      {required this.leading, required this.child, required this.trailing, this.onTap});

  final Widget leading;
  final Widget child;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSoft, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            leading,
            const SizedBox(width: 13),
            Expanded(child: child),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(height: 1.25)),
        const SizedBox(height: 2),
        Text(meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.muted)),
      ],
    );
  }
}

/// Subject / chapter result — navigates into the curriculum.
class _CatalogResult extends StatelessWidget {
  const _CatalogResult({
    required this.code,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final String code;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ResultShell(
      onTap: onTap,
      leading: HatchTile(width: 50, height: 50, radius: 13, label: code),
      trailing: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.chevron_right_rounded,
            size: 20, color: AppColors.navy),
      ),
      child: _ResultText(title: title, meta: meta),
    );
  }
}

class _LessonResult extends StatelessWidget {
  const _LessonResult({
    required this.title,
    required this.meta,
    required this.onWatch,
  });

  final String title;
  final String meta;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return _ResultShell(
      onTap: onWatch,
      leading: const HatchTile(
        width: 50,
        height: 50,
        radius: 13,
        child: Icon(Icons.play_arrow_rounded,
            size: 22, color: AppColors.navy),
      ),
      trailing: GestureDetector(
        onTap: onWatch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE7ECF6),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Text('Watch',
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy)),
        ),
      ),
      child: _ResultText(title: title, meta: meta),
    );
  }
}

/// Assessment result — opens the attempt flow.
class _TestResult extends StatelessWidget {
  const _TestResult({
    required this.title,
    required this.meta,
    required this.onStart,
  });

  final String title;
  final String meta;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _ResultShell(
      onTap: onStart,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.redBg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.assignment_outlined,
            size: 20, color: AppColors.signalRed),
      ),
      trailing: GestureDetector(
        onTap: onStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE7ECF6),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Text('Start',
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy)),
        ),
      ),
      child: _ResultText(title: title, meta: meta),
    );
  }
}

/// Lightweight launcher that defers to [HomeShell] at a given tab index.
/// Declared here to avoid a hard import cycle in the search flow.
class HomeShellLauncher extends StatelessWidget {
  const HomeShellLauncher({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return HomeShell(initialIndex: index);
  }
}
