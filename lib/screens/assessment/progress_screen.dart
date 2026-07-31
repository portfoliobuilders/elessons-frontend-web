import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/assessment.dart';
import '../../models/api/learning.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/view_status.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/loading_indicator.dart';

/// 38 · Progress — bound to GET /me/learnings, /me/stats and /me/attempts.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await Future.wait<void>(<Future<void>>[
      context.read<ProgressProvider>().loadLearnings(),
      context.read<AssessmentProvider>().loadAttempts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final assessments = context.watch<AssessmentProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = auth.user?.profile;
    final String subtitle = profile?.gradeName != null
        ? '${profile!.gradeName} · ${profile.board ?? 'CBSE'}'
        : 'Your learning';

    final List<LearningCourse> courses = progress.courses;
    final List<AttemptSummary> attempts = assessments.attempts;

    final int lessonsDone =
        courses.fold<int>(0, (int s, LearningCourse c) => s + c.completedLessons);
    final int lessonsTotal =
        courses.fold<int>(0, (int s, LearningCourse c) => s + c.totalLessons);

    final List<AttemptSummary> scored = attempts
        .where((AttemptSummary a) => (a.totalMarks ?? 0) > 0)
        .toList();
    final int avgScore = scored.isEmpty
        ? progress.stats.avgProgress
        : (scored.fold<int>(0, (int s, AttemptSummary a) => s + a.percent) /
                scored.length)
            .round();

    final int assignmentsDone = attempts
        .map((AttemptSummary a) => a.assessmentId)
        .toSet()
        .length;

    final bool loading =
        progress.status == ViewStatus.loading && courses.isEmpty;

    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('My progress',
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
          Expanded(
            child: loading
                ? const Center(child: LoadingIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.navy,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: _StatCard(
                                    label: 'Lessons done',
                                    value: '$lessonsDone',
                                    suffix: '/$lessonsTotal')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    label: 'Avg. score',
                                    value: '$avgScore%',
                                    valueColor: AppColors.success)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: _StatCard(
                                    label: 'Assignments',
                                    value: '$assignmentsDone')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    label: 'Day streak',
                                    value: '${progress.stats.dayStreak} 🔥',
                                    valueColor: AppColors.signalRed)),
                          ],
                        ),
                        if (scored.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          _RecentScores(attempts: scored),
                        ],
                        if (courses.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          _BySubject(courses: courses),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Real "recent test scores" bar chart — occupies the same visual slot as the
/// original weekly chart, driven by the learner's most recent graded attempts.
class _RecentScores extends StatelessWidget {
  const _RecentScores({required this.attempts});

  final List<AttemptSummary> attempts;

  @override
  Widget build(BuildContext context) {
    // /me/attempts returns most-recent-first; show up to 7 chronologically.
    final List<AttemptSummary> recent = attempts.take(7).toList().reversed.toList();
    int bestIdx = 0;
    for (int i = 1; i < recent.length; i++) {
      if (recent[i].percent > recent[bestIdx].percent) bestIdx = i;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Recent test scores',
              style: AppTextStyles.cardTitle
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(recent.length, (int i) {
                final AttemptSummary a = recent[i];
                final double fraction =
                    (a.percent.clamp(0, 100)) / 100.0;
                final bool highlight = i == bestIdx;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor: fraction <= 0 ? 0.02 : fraction,
                            child: Container(
                              decoration: BoxDecoration(
                                color: highlight
                                    ? AppColors.navy
                                    : const Color(0xFFE7ECF6),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text('${a.percent}',
                            style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _BySubject extends StatelessWidget {
  const _BySubject({required this.courses});

  final List<LearningCourse> courses;

  @override
  Widget build(BuildContext context) {
    final List<LearningCourse> shown = courses.take(6).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('By subject',
              style: AppTextStyles.cardTitle
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 15),
          for (int i = 0; i < shown.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 13),
            _SubjectBar(
              label: shown[i].name,
              percent: (shown[i].percent.clamp(0, 100)) / 100.0,
              value: '${shown[i].percent}%',
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.suffix,
    this.valueColor = AppColors.ink,
  });

  final String label;
  final String value;
  final String? suffix;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 7),
          Text.rich(
            TextSpan(
              text: value,
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: valueColor),
              children: <InlineSpan>[
                if (suffix != null)
                  TextSpan(
                      text: suffix,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBar extends StatelessWidget {
  const _SubjectBar({
    required this.label,
    required this.percent,
    required this.value,
  });

  final String label;
  final double percent;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText)),
            ),
            const SizedBox(width: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 7,
            backgroundColor: AppColors.trackBg,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy),
          ),
        ),
      ],
    );
  }
}
