import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/live.dart';
import '../../providers/auth_provider.dart';
import '../../providers/live_provider.dart';
import '../../providers/view_status.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

const List<String> _weekdays = <String>[
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN'
];

String _mono(String value) {
  final String letters = value.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return 'GT';
  return letters.substring(0, letters.length >= 2 ? 2 : 1).toUpperCase();
}

String _time(DateTime? dt) {
  if (dt == null) return '';
  final DateTime l = dt.toLocal();
  final int h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final String m = l.minute.toString().padLeft(2, '0');
  return '$h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
}

String _startedAgo(DateTime? dt) {
  if (dt == null) return 'in progress';
  final Duration d = DateTime.now().difference(dt.toLocal());
  if (d.isNegative) return 'starting soon';
  if (d.inMinutes < 1) return 'just started';
  if (d.inMinutes < 60) return 'started ${d.inMinutes} min ago';
  return 'started ${d.inHours}h ago';
}

/// 24 · Live Classes — schedule. Bound to GET /live-classes with reminder
/// toggles (POST /live-classes/:id/reminder[/off]). Layout unchanged.
class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({super.key});

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<LiveProvider>().loadUpcoming());
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.signalRed,
    ));
  }

  void _join(LiveClass c) {
    if (!c.hasLiveAccess) {
      _snack('This live class needs the Live + Recorded plan.');
      return;
    }
    Navigator.pushNamed(context, AppRoutes.liveRoom, arguments: {
      'classId': c.id,
      'title': c.title,
      'mentorName': c.mentorName,
      'subject': c.subject,
    });
  }

  String get _subtitle {
    final profile = context.read<AuthProvider>().user?.profile;
    final String? grade = profile?.gradeName;
    final String? board = profile?.board;
    if (grade != null && board != null) return '$grade · $board';
    return grade ?? board ?? 'Upcoming sessions';
  }

  @override
  Widget build(BuildContext context) {
    final LiveProvider provider = context.watch<LiveProvider>();

    return AppScaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            child: Row(
              children: <Widget>[
                if (Navigator.of(context).canPop()) ...<Widget>[
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
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Live Classes',
                          style: AppTextStyles.titleSm
                              .copyWith(fontSize: 16, height: 1.2)),
                      const SizedBox(height: 1),
                      Text(_subtitle,
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
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(LiveProvider provider) {
    if (provider.status == ViewStatus.loading && provider.classes.isEmpty) {
      return const LoadingIndicator(message: 'Loading schedule…');
    }
    if (provider.status == ViewStatus.error && provider.classes.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn\'t load classes',
        message: provider.error ?? 'Please try again.',
        actionLabel: 'Retry',
        onAction: () => context.read<LiveProvider>().loadUpcoming(),
      );
    }

    final List<LiveClass> live =
        provider.classes.where((LiveClass c) => c.isLive).toList();
    final List<LiveClass> upcoming = provider.classes
        .where((LiveClass c) => c.status == 'SCHEDULED')
        .toList();

    if (live.isEmpty && upcoming.isEmpty) {
      return const EmptyState(
        icon: Icons.podcasts_rounded,
        title: 'No live classes',
        message: 'There are no live or upcoming sessions right now.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      children: <Widget>[
        if (live.isNotEmpty) ...<Widget>[
          _LiveNowCard(cls: live.first, onJoin: () => _join(live.first)),
          const SizedBox(height: 22),
        ],
        if (upcoming.isNotEmpty) ...<Widget>[
          Text('This week',
              style: AppTextStyles.titleSm
                  .copyWith(fontSize: 15, letterSpacing: -0.3)),
          const SizedBox(height: 13),
          for (int i = 0; i < upcoming.length; i++) ...<Widget>[
            _ScheduleCard(
              cls: upcoming[i],
              onToggle: () => context
                  .read<LiveProvider>()
                  .toggleReminder(upcoming[i].id, !upcoming[i].reminderSet),
            ),
            if (i != upcoming.length - 1) const SizedBox(height: 11),
          ],
        ],
      ],
    );
  }
}

class _LiveNowCard extends StatelessWidget {
  const _LiveNowCard({required this.cls, required this.onJoin});

  final LiveClass cls;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final String eyebrow = cls.subject == null
        ? 'MENTOR SESSION'
        : 'MENTOR SESSION · ${cls.subject!.toUpperCase()}';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.hero,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: HatchPainter(
                        colorA: Color(0xFF21356B),
                        colorB: AppColors.navy,
                        band: 12,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 13,
                    left: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.signalRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _Dot(),
                          SizedBox(width: 5),
                          Text('LIVE NOW',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 13,
                    right: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x8C0A0E17),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.person_outline_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('${cls.watchingCount}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 22, color: AppColors.navy),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(eyebrow,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.signalRed)),
                  const SizedBox(height: 5),
                  Text(cls.title,
                      style: AppTextStyles.titleSm
                          .copyWith(fontSize: 16, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      HatchTile(
                          width: 26,
                          height: 26,
                          radius: 8,
                          label: _mono(cls.mentorName)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                            'with ${cls.mentorName} · ${_startedAgo(cls.startsAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onJoin,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.signalRed,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.signalRed.withValues(alpha: 0.6),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.play_arrow_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Join live class',
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.cls, required this.onToggle});

  final LiveClass cls;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final DateTime? s = cls.startsAt?.toLocal();
    final String day = s == null ? '' : _weekdays[(s.weekday - 1) % 7];
    final String date = s == null ? '--' : s.day.toString().padLeft(2, '0');
    final String meta = <String>[
      if (cls.subject != null) cls.subject!,
      cls.mentorName,
      if (_time(cls.startsAt).isNotEmpty) _time(cls.startsAt),
    ].join(' · ');
    final bool on = cls.reminderSet;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 54,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(day,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: AppColors.navy)),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(cls.title,
                    style: AppTextStyles.cardTitle.copyWith(height: 1.25)),
                const SizedBox(height: 3),
                Text(meta,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: on ? AppColors.navy : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.navy, width: 1.5),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                            on
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            size: 13,
                            color: on ? Colors.white : AppColors.navy),
                        const SizedBox(width: 6),
                        Text(on ? 'Reminder on' : 'Set reminder',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: on ? Colors.white : AppColors.navy)),
                      ],
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

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}
