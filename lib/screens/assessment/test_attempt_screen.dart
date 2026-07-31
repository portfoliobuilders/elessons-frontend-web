import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/view_status.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

/// 36 · Test — attempt (exam mode). Bound to GET /assessments/:id and
/// POST /assessments/:id/submit.
///
/// Args: {assessmentId, title?, subtitle?}. Loads the question paper, tracks
/// answers, runs the (optional) duration countdown, then submits for
/// auto-grading and hands the result to [TestResultScreen].
class TestAttemptScreen extends StatefulWidget {
  const TestAttemptScreen({super.key});

  @override
  State<TestAttemptScreen> createState() => _TestAttemptScreenState();
}

class _TestAttemptScreenState extends State<TestAttemptScreen> {
  static const List<String> _letters = <String>['A', 'B', 'C', 'D', 'E', 'F'];

  bool _argsRead = false;
  String? _assessmentId;
  String _title = 'Test';
  String _subtitle = '';

  AssessmentDetail? _detail;
  int _index = 0;
  final Map<String, String> _answers = <String, String>{};
  bool _submitting = false;

  Timer? _ticker;
  DateTime? _startedAt;
  int _elapsed = 0; // seconds

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _assessmentId = args['assessmentId'] as String?;
      _title = (args['title'] as String?) ?? _title;
      _subtitle = (args['subtitle'] as String?) ?? _subtitle;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final id = _assessmentId;
    if (id == null) return;
    final detail = await context.read<AssessmentProvider>().loadForAttempt(id);
    if (!mounted || detail == null) return;
    setState(() {
      _detail = detail;
      _startedAt = DateTime.now();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer _) {
    if (!mounted || _startedAt == null) return;
    final int elapsed = DateTime.now().difference(_startedAt!).inSeconds;
    setState(() => _elapsed = elapsed);
    final int? mins = _detail?.durationMinutes;
    if (mins != null && mins > 0 && elapsed >= mins * 60) {
      _ticker?.cancel();
      _submit(auto: true);
    }
  }

  String _clock() {
    final int? mins = _detail?.durationMinutes;
    // Count down when a duration is set, otherwise count up.
    final int secs = (mins != null && mins > 0)
        ? (mins * 60 - _elapsed).clamp(0, mins * 60)
        : _elapsed;
    final String mm = (secs ~/ 60).toString().padLeft(2, '0');
    final String ss = (secs % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _select(String questionId, String optionId) {
    setState(() => _answers[questionId] = optionId);
  }

  Future<void> _next() async {
    final detail = _detail;
    if (detail == null) return;
    if (_index < detail.questions.length - 1) {
      setState(() => _index += 1);
    } else {
      await _submit();
    }
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitting) return;
    final detail = _detail;
    final id = _assessmentId;
    if (detail == null || id == null) return;
    setState(() => _submitting = true);
    _ticker?.cancel();

    final AttemptResult? result =
        await context.read<AssessmentProvider>().submit(id, _answers);
    if (!mounted) return;

    if (result == null) {
      setState(() => _submitting = false);
      // Resume the timer so the learner can retry submission.
      _startedAt ??= DateTime.now();
      _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(context.read<AssessmentProvider>().error ??
              "Couldn't submit your answers."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.signalRed,
        ));
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.testResult,
      arguments: <String, dynamic>{
        'result': result,
        'title': _title,
        'subtitle': _subtitle,
        'elapsedLabel': _elapsedLabel(),
      },
    );
  }

  String _elapsedLabel() {
    final String mm = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final String ss = (_elapsed % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();
    final AssessmentDetail? detail = _detail;

    if (detail == null) {
      if (provider.status == ViewStatus.error) {
        return AppScaffold(
          backgroundColor: AppColors.surface,
          body: Center(
            child: EmptyState(
              icon: Icons.wifi_off_rounded,
              title: "Couldn't load the test",
              message: provider.error ?? 'Please try again.',
              actionLabel: 'Retry',
              onAction: _load,
            ),
          ),
        );
      }
      return const AppScaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: LoadingIndicator(message: 'Preparing your test…')),
      );
    }

    final List<Question> questions = detail.questions;
    final Question q = questions[_index];
    final int total = questions.length;
    final int answered = _answers.length;
    final double progress = total == 0 ? 0 : (_index + 1) / total;
    final int fillFlex = (progress * 100).round().clamp(1, 100);

    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // exam top bar
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_subtitle.isNotEmpty ? _subtitle : _title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: Colors.white)),
                      const SizedBox(height: 1),
                      Text('Question ${_index + 1} of $total',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onNavyAccent)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.signalRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.timer_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 7),
                      Text(_clock(),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // progress
          SizedBox(
            height: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: fillFlex,
                    child: Container(color: AppColors.signalRed)),
                Expanded(
                    flex: (100 - fillFlex).clamp(0, 100),
                    child: Container(color: const Color(0xFFE4E8EF))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              children: <Widget>[
                Text(q.text,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.4,
                        color: AppColors.ink)),
                const SizedBox(height: 22),
                ...List<Widget>.generate(q.options.length, (int i) {
                  final QuestionOption opt = q.options[i];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: i == q.options.length - 1 ? 0 : 12),
                    child: _OptionTile(
                      letter: i < _letters.length ? _letters[i] : '${i + 1}',
                      text: opt.text,
                      selected: _answers[q.id] == opt.id,
                      onTap: () => _select(q.id, opt.id),
                    ),
                  );
                }),
                const SizedBox(height: 22),
                _QuestionPalette(
                  total: total,
                  current: _index,
                  answeredIds: _answers.keys.toSet(),
                  questions: questions,
                  answeredCount: answered,
                  onJump: (int i) => setState(() => _index = i),
                ),
              ],
            ),
          ),
          // bottom controls
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 13, 20, 22 + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (_index > 0) {
                      setState(() => _index -= 1);
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        size: 20, color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: GestureDetector(
                    onTap: _submitting ? null : _next,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.primaryButton,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white)),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    _index == total - 1
                                        ? 'Submit test'
                                        : 'Save & next',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                const SizedBox(width: 9),
                                Icon(
                                    _index == total - 1
                                        ? Icons.check_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSoft : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: selected ? AppColors.navy : AppColors.border,
              width: selected ? 2 : 1.5),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    spreadRadius: -12,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : Colors.transparent,
                shape: BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFD6DBE5), width: 2),
              ),
              child: Text(letter,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.muted)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? AppColors.ink : AppColors.bodyText)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPalette extends StatelessWidget {
  const _QuestionPalette({
    required this.total,
    required this.current,
    required this.answeredIds,
    required this.questions,
    required this.answeredCount,
    required this.onJump,
  });

  final int total;
  final int current;
  final Set<String> answeredIds;
  final List<Question> questions;
  final int answeredCount;
  final ValueChanged<int> onJump;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Question palette',
                  style: AppTextStyles.cardTitle
                      .copyWith(fontSize: 12.5, fontWeight: FontWeight.w800)),
              Text('$answeredCount of $total answered',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 7,
            crossAxisSpacing: 7,
            children: List<Widget>.generate(total, (int i) {
              final bool isAnswered = answeredIds.contains(questions[i].id);
              final bool isCurrent = i == current;
              final Color c = isAnswered
                  ? AppColors.success
                  : (isCurrent ? AppColors.navy : AppColors.signalRed);
              return GestureDetector(
                onTap: () => onJump(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isCurrent
                        ? <BoxShadow>[
                            const BoxShadow(
                                color: AppColors.navy,
                                blurRadius: 0,
                                spreadRadius: 2),
                          ]
                        : null,
                  ),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              );
            }),
          ),
          const SizedBox(height: 13),
          const Wrap(
            spacing: 14,
            runSpacing: 8,
            children: <Widget>[
              _LegendDot(color: AppColors.success, label: 'Answered'),
              _LegendDot(color: AppColors.signalRed, label: 'Not answered'),
              _LegendDot(color: AppColors.navy, label: 'Current'),
            ],
          ),
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
