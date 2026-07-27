import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/live.dart';
import '../../providers/live_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';

String _mono(String? value, {String fallback = 'GT'}) {
  final String letters = (value ?? '').replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return fallback;
  return letters.substring(0, letters.length >= 2 ? 2 : 1).toUpperCase();
}

/// 25 · Live Class Room — bound to GET /live-classes/:id/join (room) and the
/// chat endpoints. Video playback opens the mentor's YouTube live stream via
/// url_launcher (no embedded player package); chat posts through POST
/// /live-classes/:id/chat and refreshes on a short poll. Layout unchanged.
class LiveRoomScreen extends StatefulWidget {
  const LiveRoomScreen({super.key});

  static const Color _stageBg = Color(0xFF0E1424);

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  bool _argsRead = false;
  String? _classId;
  String? _argTitle;
  String? _argMentor;
  String? _argSubject;

  bool _joining = true;
  String? _joinError;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _poll;
  int _lastCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final Object? raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      _classId = raw['classId'] as String?;
      _argTitle = raw['title'] as String?;
      _argMentor = raw['mentorName'] as String?;
      _argSubject = raw['subject'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_classId == null) {
      setState(() {
        _joining = false;
        _joinError = 'This live class could not be opened.';
      });
      return;
    }
    setState(() {
      _joining = true;
      _joinError = null;
    });
    final String? err = await context.read<LiveProvider>().join(_classId!);
    if (!mounted) return;
    setState(() {
      _joining = false;
      _joinError = err;
    });
    if (err == null) {
      _poll = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted && _classId != null) {
          context.read<LiveProvider>().refreshChat(_classId!);
        }
      });
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.signalRed,
    ));
  }

  Future<void> _openStream() async {
    final LiveRoom? room = context.read<LiveProvider>().room;
    final String? yt = room?.youtubeId;
    if (yt == null || yt.isEmpty) {
      _snack('The live stream isn\'t available to open.');
      return;
    }
    final Uri uri = Uri.parse('https://www.youtube.com/watch?v=$yt');
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) _snack('Couldn\'t open the live stream.');
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _classId == null) return;
    _controller.clear();
    final String? err =
        await context.read<LiveProvider>().sendMessage(_classId!, text);
    if (err != null) _snack(err);
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final LiveProvider provider = context.watch<LiveProvider>();
    final LiveRoom? room = provider.room;

    final String mentor = room?.mentorName ?? _argMentor ?? 'Mentor';
    final String label = _argSubject != null
        ? '$mentor · ${_argSubject!}'
        : (_argTitle != null ? '$mentor · ${_argTitle!}' : mentor);
    final int watching = room?.watchingCount ?? 0;

    // Sort chat oldest→newest for natural top-to-bottom reading.
    final List<LiveChatMessage> messages =
        List<LiveChatMessage>.of(provider.messages)
          ..sort((LiveChatMessage a, LiveChatMessage b) {
            final DateTime ax =
                a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final DateTime bx =
                b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return ax.compareTo(bx);
          });
    if (messages.length != _lastCount) {
      _lastCount = messages.length;
      _scrollToBottomSoon();
    }

    return AppScaffold(
      backgroundColor: LiveRoomScreen._stageBg,
      dark: true,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _stage(mentor, label, watching),
          Expanded(child: _chatArea(messages, mentor)),
          _controlBar(),
        ],
      ),
    );
  }

  Widget _stage(String mentor, String label, int watching) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: _joining ? null : _openStream,
              child: const CustomPaint(
                painter: HatchPainter(
                  colorA: Color(0xFF11182B),
                  colorB: LiveRoomScreen._stageBg,
                  band: 14,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 16,
            child: Row(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.signalRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _Dot(),
                      SizedBox(width: 5),
                      Text('LIVE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.person_outline_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text('$watching watching',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: _joining
                ? const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: Colors.white),
                  )
                : GestureDetector(
                    onTap: _openStream,
                    child: Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5),
                      ),
                      child: Text(_mono(mentor),
                          style: AppTextStyles.mono.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onNavyAccent)),
                    ),
                  ),
          ),
          Positioned(
            bottom: 14,
            left: 16,
            right: 88,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x990A0E17),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              width: 64,
              height: 84,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF2A3450), Color(0xFF1E2740)],
                ),
              ),
              child: const Text('You',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onNavySubtle)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatArea(List<LiveChatMessage> messages, String mentor) {
    if (_joinError != null) {
      return Container(
        color: AppColors.surface,
        child: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Can\'t join this class',
          message: _joinError!,
          actionLabel: 'Try again',
          onAction: _join,
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        children: <Widget>[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text('Live chat',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted)),
            ),
          ),
          const SizedBox(height: 14),
          if (messages.isEmpty && !_joining)
            const Padding(
              padding: EdgeInsets.only(top: 28),
              child: Text('No messages yet — say hello 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted)),
            )
          else
            for (final LiveChatMessage m in messages)
              _ChatMessage(
                code: _mono(m.userName, fallback: 'GT'),
                name: m.userName == mentor
                    ? '$mentor · Mentor'
                    : (m.userName ?? 'Student'),
                message: m.message,
                nameColor:
                    m.userName == mentor ? AppColors.navy : AppColors.ink,
                mentorAvatar: m.userName == mentor,
                bubble: m.userName == mentor,
              ),
        ],
      ),
    );
  }

  Widget _controlBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      padding: EdgeInsets.fromLTRB(
          18, 12, 18, 22 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: <Widget>[
          const _ControlButton(
            icon: Icons.mic_none_rounded,
            background: AppColors.surfaceAlt,
            iconColor: AppColors.navy,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                cursorColor: AppColors.navy,
                enabled: _joinError == null,
                style: AppTextStyles.body.copyWith(color: AppColors.ink),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Ask a question…',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 11),
          const _ControlButton(
            icon: Icons.back_hand_outlined,
            background: Color(0xFFE7ECF6),
            iconColor: AppColors.navy,
          ),
          const SizedBox(width: 11),
          _ControlButton(
            icon: Icons.call_end_rounded,
            background: AppColors.signalRed,
            iconColor: Colors.white,
            elevated: true,
            onTap: () => Navigator.maybePop(context),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({
    required this.code,
    required this.name,
    required this.message,
    this.nameColor = AppColors.ink,
    this.mentorAvatar = false,
    this.bubble = false,
  });

  final String code;
  final String name;
  final String message;
  final Color nameColor;
  final bool mentorAvatar;
  final bool bubble;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (mentorAvatar)
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(code,
                  style: AppTextStyles.mono
                      .copyWith(fontSize: 9, color: AppColors.onNavyAccent)),
            )
          else
            HatchTile(width: 30, height: 30, radius: 9, label: code, band: 5),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: nameColor)),
                const SizedBox(height: 2),
                if (bubble)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: AppColors.bodyText)),
                  )
                else
                  Text(message,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: AppColors.bodyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.elevated = false,
    this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final bool elevated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          boxShadow: elevated
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.signalRed.withValues(alpha: 0.6),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 20, color: iconColor),
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
