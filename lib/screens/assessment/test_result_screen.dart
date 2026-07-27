import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/assessment.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';

/// 37 · Test Result — renders the auto-graded [AttemptResult] returned by
/// POST /assessments/:id/submit.
///
/// Args: {result: AttemptResult, title?, subtitle?, elapsedLabel?}.
class TestResultScreen extends StatelessWidget {
  const TestResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    AttemptResult? result;
    String subtitle = 'Result';
    String elapsedLabel = '—';
    if (args is Map) {
      final r = args['result'];
      if (r is AttemptResult) result = r;
      subtitle = (args['subtitle'] as String?) ?? subtitle;
      elapsedLabel = (args['elapsedLabel'] as String?) ?? elapsedLabel;
    }

    if (result == null) {
      return AppScaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: EmptyState(
            icon: Icons.assignment_turned_in_outlined,
            title: 'No result to show',
            message: 'Complete a test to see your score here.',
            actionLabel: 'Back to home',
            onAction: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (_) => false),
          ),
        ),
      );
    }

    final AttemptResult r = result;
    final int wrong = (r.questionCount - r.correctCount).clamp(0, r.questionCount);
    final double ratio = (r.percent.clamp(0, 100)) / 100.0;
    final bool passed = r.percent >= 40;

    final GlobalKey reviewKey = GlobalKey();

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
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (_) => false),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Result',
                          style: AppTextStyles.titleSm
                              .copyWith(fontSize: 16, height: 1.2)),
                      const SizedBox(height: 1),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              children: <Widget>[
                // score card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: ratio,
                            color: passed
                                ? AppColors.success
                                : AppColors.signalRed,
                            track: AppColors.trackBg,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('${r.percent}%',
                                    style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.8,
                                        color: AppColors.ink)),
                                Text('${r.correctCount} / ${r.questionCount} correct',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: passed
                              ? AppColors.successBg
                              : AppColors.redBg,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                                passed
                                    ? Icons.check_rounded
                                    : Icons.refresh_rounded,
                                size: 15,
                                color: passed
                                    ? AppColors.success
                                    : AppColors.signalRed),
                            const SizedBox(width: 7),
                            Text(
                                passed
                                    ? 'Passed · Great work!'
                                    : 'Keep practising',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: passed
                                        ? const Color(0xFF14633F)
                                        : AppColors.signalRed)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: _StatTile(
                            value: '${r.correctCount}',
                            label: 'Correct',
                            color: AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatTile(
                            value: '$wrong',
                            label: 'Wrong',
                            color: AppColors.signalRed)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatTile(
                            value: elapsedLabel,
                            label: 'Time',
                            color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 16),
                if (r.review.isNotEmpty)
                  Container(
                    key: reviewKey,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Answer review',
                                style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                            Text('${r.score} / ${r.totalMarks} marks',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        GridView.count(
                          crossAxisCount: 8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 7,
                          crossAxisSpacing: 7,
                          children:
                              List<Widget>.generate(r.review.length, (int i) {
                            final QuestionReview qr = r.review[i];
                            final Color c = qr.isCorrect
                                ? AppColors.success
                                : AppColors.signalRed;
                            return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            );
                          }),
                        ),
                        const SizedBox(height: 13),
                        const Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: <Widget>[
                            _LegendDot(
                                color: AppColors.success, label: 'Correct'),
                            _LegendDot(
                                color: AppColors.signalRed, label: 'Incorrect'),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (r.review.isNotEmpty) const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final ctx = reviewKey.currentContext;
                          if (ctx != null) {
                            Scrollable.ensureVisible(ctx,
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOut);
                          }
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border:
                                Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: const Text('Review answers',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.home, (_) => false),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: AppShadows.primaryButton,
                          ),
                          child: const Text('Back to course',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedAlt)),
      ],
    );
  }
}

/// Paints a circular progress ring (stand-in for the design's conic-gradient).
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 18;
    final Offset center = size.center(Offset.zero);
    final double radius = (size.width - stroke) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    const double start = -1.5707963; // -90°, top
    canvas.drawArc(rect, start, 6.2831853 * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
