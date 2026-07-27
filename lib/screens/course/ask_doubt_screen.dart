import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/doubt.dart';
import '../../providers/doubt_provider.dart';
import '../../providers/view_status.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

String _initials(String? name, {String fallback = 'GT'}) {
  final String n = (name ?? '').trim();
  if (n.isEmpty) return fallback;
  final List<String> parts = n.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (parts.first[0] + parts[1][0]).toUpperCase();
}

String _ago(DateTime? dt) {
  if (dt == null) return '';
  final Duration d = DateTime.now().difference(dt);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays == 1) return 'yesterday';
  if (d.inDays < 7) return '${d.inDays} days ago';
  if (d.inDays < 30) return '${(d.inDays / 7).floor()}w ago';
  if (d.inDays < 365) return '${(d.inDays / 30).floor()}mo ago';
  return '${(d.inDays / 365).floor()}y ago';
}

/// 23 · Ask a Doubt — Q&A. Bound to GET /lessons/:id/doubts (answered thread)
/// with new questions posted via POST /doubts. Opened without a lesson it
/// shows the learner's own questions (GET /me/doubts). Layout unchanged.
class AskDoubtScreen extends StatefulWidget {
  const AskDoubtScreen({super.key});

  @override
  State<AskDoubtScreen> createState() => _AskDoubtScreenState();
}

class _AskDoubtScreenState extends State<AskDoubtScreen> {
  bool _argsRead = false;
  String? _lessonId;
  String? _lessonTitle;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final Object? raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      _lessonId = raw['lessonId'] as String?;
      _lessonTitle = raw['lessonTitle'] as String? ?? raw['title'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _load() {
    final DoubtProvider p = context.read<DoubtProvider>();
    return _lessonId != null ? p.loadForLesson(_lessonId!) : p.loadMine();
  }

  void _snack(String message, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.signalRed : AppColors.navy,
    ));
  }

  Future<void> _send() async {
    final String q = _controller.text.trim();
    if (q.isEmpty) return;
    if (_lessonId == null) {
      _snack('Open a lesson to ask a doubt.');
      return;
    }
    final String? err = await context
        .read<DoubtProvider>()
        .ask(lessonId: _lessonId!, question: q);
    if (!mounted) return;
    if (err == null) {
      _controller.clear();
      _focus.unfocus();
      _snack('Your doubt was posted.', error: false);
      await context.read<DoubtProvider>().loadForLesson(_lessonId!);
    } else {
      _snack(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DoubtProvider provider = context.watch<DoubtProvider>();

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Q&A · Doubts',
                          style: AppTextStyles.titleSm
                              .copyWith(fontSize: 16, height: 1.2)),
                      const SizedBox(height: 1),
                      Text(
                          _lessonTitle?.trim().isNotEmpty == true
                              ? _lessonTitle!
                              : 'Your questions',
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
          Expanded(child: _list(provider)),
          _askBar(provider),
        ],
      ),
    );
  }

  Widget _list(DoubtProvider provider) {
    final List<Doubt> items =
        _lessonId != null ? provider.lessonDoubts : provider.mine;

    if (provider.status == ViewStatus.loading && items.isEmpty) {
      return const LoadingIndicator(message: 'Loading doubts…');
    }
    if (provider.status == ViewStatus.error && items.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn\'t load doubts',
        message: provider.error ?? 'Please try again.',
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.forum_outlined,
        title: 'No doubts yet',
        message: _lessonId != null
            ? 'Be the first to ask about this lesson.'
            : 'You haven\'t asked any questions yet.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (BuildContext context, int i) => _thread(items[i]),
    );
  }

  Widget _thread(Doubt d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  HatchTile(
                      width: 34,
                      height: 34,
                      radius: 10,
                      label: _initials(d.studentName, fallback: 'You')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(d.studentName ?? 'You',
                            style:
                                AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                        const SizedBox(height: 1),
                        Text(
                          <String>[
                            if (_ago(d.createdAt).isNotEmpty) _ago(d.createdAt),
                            if (_lessonId == null && d.lessonTitle != null)
                              d.lessonTitle!,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  _statusTag(d.status),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                d.question,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: AppColors.bodyText),
              ),
            ],
          ),
        ),
        if (d.answer != null && d.answer!.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: const Border(
                    left: BorderSide(color: AppColors.navy, width: 3)),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_initials(d.teacherName, fallback: 'GT'),
                            style: AppTextStyles.mono.copyWith(
                                fontSize: 10, color: AppColors.onNavyAccent)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text.rich(
                              TextSpan(
                                text: '${d.teacherName ?? 'Educator'} ',
                                style: AppTextStyles.cardTitle
                                    .copyWith(fontSize: 13),
                                children: const <InlineSpan>[
                                  TextSpan(
                                      text: '· Educator',
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navy)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(_ago(d.answeredAt),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    d.answer!,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        height: 1.55,
                        color: AppColors.bodyText),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context
                        .read<DoubtProvider>()
                        .toggleHelpful(d.id, lessonId: _lessonId),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.thumb_up_outlined,
                            size: 15, color: AppColors.navy),
                        const SizedBox(width: 6),
                        Text('Helpful · ${d.helpfulCount}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusTag(String status) {
    switch (status) {
      case 'ANSWERED':
        return const _Tag(
            label: 'ANSWERED', color: AppColors.success, bg: AppColors.successBg);
      case 'CLOSED':
        return const _Tag(
            label: 'CLOSED', color: AppColors.slate, bg: AppColors.surfaceAlt);
      case 'OPEN':
      default:
        return const _Tag(
            label: 'OPEN', color: AppColors.navy, bg: Color(0xFFE7ECF6));
    }
  }

  Widget _askBar(DoubtProvider provider) {
    final bool submitting = provider.isSubmitting;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 13, 20, 22 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                cursorColor: AppColors.navy,
                style: AppTextStyles.body.copyWith(color: AppColors.ink),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Ask a doubt…',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 11),
          GestureDetector(
            onTap: submitting ? null : _send,
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.input),
                boxShadow: AppShadows.floating,
              ),
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
    );
  }
}
