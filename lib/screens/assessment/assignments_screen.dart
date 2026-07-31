import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/view_status.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

/// Friendly label for a backend assessment type code.
String _typeLabel(String type) {
  switch (type) {
    case 'PYQ':
      return 'Previous year';
    case 'ASSIGNMENT':
      return 'Assignment';
    case 'PRACTICE_QUIZ':
      return 'Practice quiz';
    case 'MOCK_TEST':
    default:
      return 'Mock test';
  }
}

/// 35 · Assignments — bound to GET /assessments.
///
/// Args (all optional): {subjectId?, chapterId?, type?}. Filters the list, and
/// derives the To-do / Completed split from whether an attempt exists
/// (bestScore != null).
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  int _filter = 0; // 0 = All, 1 = To do, 2 = Completed
  bool _argsRead = false;
  String? _subjectId;
  String? _chapterId;
  String? _type;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _subjectId = args['subjectId'] as String?;
      _chapterId = args['chapterId'] as String?;
      _type = args['type'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    return context.read<AssessmentProvider>().loadList(
          subjectId: _subjectId,
          chapterId: _chapterId,
          type: _type,
        );
  }

  void _start(AssessmentListItem item) {
    if (!item.hasAccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Purchase this course to unlock the test.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.signalRed,
        ));
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.testAttempt,
      arguments: <String, dynamic>{
        'assessmentId': item.id,
        'title': item.title,
        'subtitle': '${_typeLabel(item.type)} · ${item.questionCount} questions',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = auth.user?.profile;
    final subtitle = profile?.gradeName != null
        ? '${profile!.gradeName} · ${profile.board ?? 'CBSE'}'
        : 'Assessments';

    final List<AssessmentListItem> all = provider.items;
    final List<AssessmentListItem> todo =
        all.where((AssessmentListItem a) => a.bestScore == null).toList();
    final List<AssessmentListItem> done =
        all.where((AssessmentListItem a) => a.bestScore != null).toList();

    final List<String> filters = <String>[
      'All · ${all.length}',
      'To do · ${todo.length}',
      'Completed · ${done.length}',
    ];
    final List<AssessmentListItem> visible =
        _filter == 1 ? todo : (_filter == 2 ? done : all);

    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Assignments',
                              style: AppTextStyles.titleSm
                                  .copyWith(fontSize: 16, height: 1.2)),
                          const SizedBox(height: 1),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: List<Widget>.generate(filters.length, (int i) {
                      final bool active = i == _filter;
                      return Padding(
                        padding: EdgeInsets.only(
                            right: i == filters.length - 1 ? 0 : 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = i),
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color:
                                  active ? AppColors.navy : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(filters[i],
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : AppColors.bodyText)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(provider, visible)),
        ],
      ),
    );
  }

  Widget _body(AssessmentProvider provider, List<AssessmentListItem> visible) {
    if (provider.status == ViewStatus.loading && provider.items.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    if (provider.status == ViewStatus.error && provider.items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: "Couldn't load assignments",
          message: provider.error ?? 'Please try again.',
          actionLabel: 'Retry',
          onAction: _load,
        ),
      );
    }
    if (visible.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.assignment_outlined,
          title: 'Nothing here yet',
          message: 'New assignments will appear here as they are published.',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.navy,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 13),
        itemBuilder: (BuildContext context, int i) {
          final AssessmentListItem item = visible[i];
          if (item.bestScore != null) {
            return _GradedCard(
              title: item.title,
              meta:
                  '${_typeLabel(item.type)} · ${item.questionCount} questions',
              score: '${item.bestScore}',
              total: item.totalMarks != null ? '/${item.totalMarks}' : '',
            );
          }
          return _PendingCard(
            title: item.title,
            meta: '${_typeLabel(item.type)} · ${item.questionCount} questions',
            due: item.durationMinutes != null
                ? '${item.durationMinutes} min'
                : (item.hasAccess ? 'Ready' : 'Locked'),
            dueUrgent: !item.hasAccess,
            locked: !item.hasAccess,
            onStart: () => _start(item),
          );
        },
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.title,
    required this.meta,
    required this.due,
    required this.dueUrgent,
    required this.onStart,
    this.locked = false,
  });

  final String title;
  final String meta;
  final String due;
  final bool dueUrgent;
  final bool locked;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined,
                    size: 20, color: AppColors.signalRed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: AppTextStyles.cardTitle.copyWith(height: 1.25)),
                    const SizedBox(height: 2),
                    Text(meta,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(locked ? Icons.lock_outline_rounded : Icons.schedule_rounded,
                      size: 13,
                      color: dueUrgent ? AppColors.signalRed : AppColors.slate),
                  const SizedBox(width: 6),
                  Text(due,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                              dueUrgent ? AppColors.signalRed : AppColors.slate)),
                ],
              ),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(locked ? 'Unlock' : 'Start',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradedCard extends StatelessWidget {
  const _GradedCard({
    required this.title,
    required this.meta,
    required this.score,
    required this.total,
  });

  final String title;
  final String meta;
  final String score;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.92,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 20, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: AppTextStyles.cardTitle.copyWith(height: 1.25)),
                  const SizedBox(height: 2),
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
                Text.rich(
                  TextSpan(
                    text: score,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.success),
                    children: <InlineSpan>[
                      TextSpan(
                          text: total,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.muted)),
                    ],
                  ),
                ),
                const Text('Best score',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
