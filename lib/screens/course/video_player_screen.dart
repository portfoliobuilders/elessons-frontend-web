import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtec_app/screens/course/video_player.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../core/services/video_player_service.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/trailer_artwork.dart';
import '../../core/utils/hatch_painter.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/web_security.dart';
import '../../core/utils/youtube_utils.dart';
import '../../models/api/catalog.dart';
import '../../providers/catalog_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

/// Premium EdTech Lesson Video Player Screen (Byju's / Unacademy / Udemy style).
///
/// Features:
/// - Custom Flutter video player controls overlay (Play/Pause, Replay 10s, Forward 10s, Slider, Fullscreen).
/// - Double-tap left/right side gestures for quick 10-second rewind/forward.
/// - Auto-hiding controls after 3 seconds of inactivity.
/// - Complete subject isolation & controller disposal on lesson switch.
/// - Full gating check (hasAccess & locked) before player initialization.
/// - Pluggable VideoPlayerService architecture (YouTube, Cloudflare R2, AWS S3).
/// - Telemetry logs for debugging player lifecycle and states.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _argsRead = false;
  String? _lessonId;
  String? _argTitle;
  String? _subjectName;
  String? _chapterName;

  String? _prevLessonId;
  String? _prevLessonTitle;
  String? _nextLessonId;
  String? _nextLessonTitle;

  bool _loading = true;
  String? _error;
  LessonDetail? _lesson;
  VideoSource? _videoSource;

  // YoutubePlayerController? _ytController;
  // StreamSubscription<YoutubePlayerValue>? _streamSub;

  bool _inlineError = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isStarted = false;
  bool _showControls = true;
  bool _isFullscreen = false;

  double _currentPositionSec = 0;
  double _totalDurationSec = 0;
  Timer? _controlsTimer;

  bool _showSeekFeedbackLeft = false;
  bool _showSeekFeedbackRight = false;
  Timer? _feedbackTimerLeft;
  Timer? _feedbackTimerRight;
  String? _videoId;

  int _tab = 0;
  static const List<String> _tabs = <String>[
    'Overview',
    'Notes',
    'PYQs',
    'Resources'
  ];

  @override
  void initState() {
    super.initState();
    setupWebSecurityShield();
    if (!kIsWeb) {
      try {
        ScreenProtector.preventScreenshotOn();
      } catch (e) {
        debugPrint('🛡️ [VideoPlayerScreen]: Screen protector setup: $e');
      }
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 [VideoPlayerScreen]: Disposing screen resources & player');
    cleanupWebSecurityShield();
    if (!kIsWeb) {
      try {
        ScreenProtector.preventScreenshotOff();
      } catch (e) {
        debugPrint('🛡️ [VideoPlayerScreen]: Screen protector cleanup: $e');
      }
    }
    _disposePlayer();
    _controlsTimer?.cancel();
    _feedbackTimerLeft?.cancel();
    _feedbackTimerRight?.cancel();

    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
    }
    super.dispose();
  }

  void _disposePlayer() {
    _controlsTimer?.cancel();
    // _streamSub?.cancel();
    // _streamSub = null;
    // _ytController?.close();
    // _ytController = null;

    _isStarted = false;
    _isPlaying = false;
    _isBuffering = false;
    _inlineError = false;
    _currentPositionSec = 0;
    _totalDurationSec = 0;
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    if (_showControls && _isPlaying) {
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _initYoutubePlayer(String rawVideoId) {
    _disposePlayer();

    final String? cleanId = extractYouTubeId(rawVideoId);
    if (cleanId == null || cleanId.length != 11) {
      debugPrint(
          '⚠️ [VideoPlayerScreen]: Invalid YouTube Video ID: "$rawVideoId"');
      setState(() {
        _inlineError = true;
      });
      return;
    }

    debugPrint(
        '▶️ [VideoPlayerScreen]: Initializing Custom Player for Video ID: $cleanId');
    _videoId = cleanId;
    // final controller = YoutubePlayerController.fromVideoId(
    //   videoId: cleanId,
    //   autoPlay: false,
    //   params: const YoutubePlayerParams(
    //     showControls: false,
    //     showFullscreenButton: false,
    //     mute: false,
    //     loop: false,
    //     playsInline: true,
    //     strictRelatedVideos: true,
    //     enableCaption: false,
    //     // IMPORTANT: enableJavaScript true improves seek reliability
    //     enableJavaScript: true,
    //     // Block pointer interactions; we render our own controls
    //     pointerEvents: PointerEvents.none,
    //   ),
    // );

    // _streamSub = controller.stream.listen((YoutubePlayerValue value) async {
    //   if (!mounted) return;

    //   final bool isPlayingNow = value.playerState == PlayerState.playing;
    //   final bool isBufferingNow = value.playerState == PlayerState.buffering;

    //   if (isPlayingNow || isBufferingNow) {
    //     if (!_isStarted) {
    //       _isStarted = true;
    //     }
    //   }

    //   final double pos = await controller.currentTime;
    //   final double dur = await controller.duration;

    //   if (!mounted) return;

    //   setState(() {
    //     _isPlaying = isPlayingNow;
    //     _isBuffering = isBufferingNow;
    //     if (pos >= 0) _currentPositionSec = pos;
    //     if (dur > 0) _totalDurationSec = dur;
    //   });

    //   if (value.error != YoutubeError.none &&
    //       value.error != YoutubeError.unknown) {
    //     debugPrint(
    //         '⚠️ [VideoPlayerScreen]: Player Error Received: ${value.error}');
    //     setState(() {
    //       _inlineError = true;
    //     });
    //   }

    //   _resetControlsTimer();
    // });

    // _ytController = controller;
    // debugPrint('✅ [VideoPlayerScreen]: Player Controller State: READY');
  }

  // void _seekRelative(double deltaSeconds) async {
  //   if (_ytController == null) return;
  //   final double current = _currentPositionSec;
  //   final double duration = _totalDurationSec;
  //   double target = current + deltaSeconds;
  //   if (target < 0) target = 0;
  //   if (duration > 0 && target > duration) target = duration;

  //   _ytController!.seekTo(seconds: target, allowSeekAhead: true);
  //   setState(() {
  //     _currentPositionSec = target;
  //     _showControls = true;
  //   });
  //   _resetControlsTimer();

  //   if (deltaSeconds < 0) {
  //     _feedbackTimerLeft?.cancel();
  //     setState(() => _showSeekFeedbackLeft = true);
  //     _feedbackTimerLeft = Timer(const Duration(milliseconds: 750), () {
  //       if (mounted) setState(() => _showSeekFeedbackLeft = false);
  //     });
  //   } else {
  //     _feedbackTimerRight?.cancel();
  //     setState(() => _showSeekFeedbackRight = true);
  //     _feedbackTimerRight = Timer(const Duration(milliseconds: 750), () {
  //       if (mounted) setState(() => _showSeekFeedbackRight = false);
  //     });
  //   }
  // }

  // void _togglePlayPause() {
  //   if (_ytController == null) return;
  //   if (_isPlaying) {
  //     _ytController!.pauseVideo();
  //     setState(() {
  //       _isPlaying = false;
  //       _showControls = true;
  //     });
  //     _controlsTimer?.cancel();
  //   } else {
  //     _startPlayback();
  //   }
  // }

  // void _startPlayback() {
  //   setState(() {
  //     _isStarted = true;
  //     _isPlaying = true;
  //     _showControls = true;
  //   });
  //   _ytController?.playVideo();
  //   _resetControlsTimer();
  // }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final Object? raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      _lessonId = raw['lessonId'] as String?;
      _argTitle = raw['title'] as String?;
      _subjectName = raw['subjectName'] as String?;
      _chapterName = raw['chapterName'] as String?;
      _prevLessonId = raw['prevLessonId'] as String?;
      _prevLessonTitle = raw['prevLessonTitle'] as String?;
      _nextLessonId = raw['nextLessonId'] as String?;
      _nextLessonTitle = raw['nextLessonTitle'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_lessonId == null) {
      setState(() {
        _loading = false;
        _error = 'This lesson could not be opened.';
      });
      return;
    }

    _disposePlayer();

    setState(() {
      _loading = true;
      _error = null;
    });

    debugPrint('=== [VideoPlayerScreen Telemetry] ===');
    debugPrint('Selected Subject Name : ${_subjectName ?? "N/A"}');
    debugPrint('Selected Chapter Name : ${_chapterName ?? "N/A"}');
    debugPrint('Selected Lesson ID   : $_lessonId');
    print('*** VideoPlayerScreen loading lesson id: $_lessonId ***');

    final LessonDetail? lesson =
        await context.read<CatalogProvider>().loadLesson(_lessonId!);
    if (!mounted) return;

    final VideoSource source = VideoPlayerService.resolveSource(lesson);
    _videoSource = source;

    debugPrint('Resolved Source Type  : ${source.type}');
    debugPrint('Source Validity       : ${source.isValid}');
    debugPrint(
        'Has Access / Unlocked : ${lesson?.hasAccess == true && lesson?.locked == false}');

    if (lesson != null &&
        lesson.hasAccess &&
        !lesson.locked &&
        source.isValid) {
      if (source.type == VideoSourceType.youtube && source.videoId != null) {
        _initYoutubePlayer(source.videoId!);
      }
    } else {
      debugPrint(
          '🔒 [VideoPlayerScreen]: Access restricted or no video source. Controller skipped.');
    }

    setState(() {
      _lesson = lesson;
      _loading = false;
      if (lesson == null) {
        _error = context.read<CatalogProvider>().error ??
            'This lesson could not be loaded.';
      }
    });
  }

  void _retryPlayer() {
    final VideoSource? source = _videoSource;
    if (source != null &&
        source.type == VideoSourceType.youtube &&
        source.videoId != null) {
      setState(() {
        _inlineError = false;
      });
      _initYoutubePlayer(source.videoId!);
    } else {
      _load();
    }
  }

  void _switchLesson(String newLessonId, {String? title}) {
    debugPrint(
        '🔄 [VideoPlayerScreen]: Switching to new Lesson ID: $newLessonId');
    _disposePlayer();
    setState(() {
      _lessonId = newLessonId;
      if (title != null) _argTitle = title;
      _lesson = null;
      _videoId = null;
      _videoSource = null;
      _loading = true;
      _error = null;
    });
    _load();
  }

  void _openResource(ResourceItem r) => Navigator.pushNamed(
        context,
        AppRoutes.pdfViewer,
        arguments: {
          'resourceId': r.id,
          'fileKey': r.fileKey,
          'title': r.title,
          'lessonId': _lessonId,
          'pageCount': r.pageCount,
          'sizeLabel': r.sizeLabel,
          'type': r.type,
        },
      );

  String _formatDuration(double seconds) {
    if (seconds.isNaN || seconds < 0) return '00:00';
    final int totalSec = seconds.round();
    final int minutes = totalSec ~/ 60;
    final int secs = totalSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktopView = context.isDesktop;

    if (isDesktopView && !_isFullscreen) {
      return AppScaffold(
        safeTop: true,
        dark: true,
        clampWidth: false,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 65,
              child: Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _stage(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 35,
              child: Container(
                color: Colors.white,
                child: _body(),
              ),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      safeTop: !_isFullscreen,
      dark: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _stage(),
          if (!_isFullscreen)
            Expanded(
              child: Container(
                color: Colors.white,
                child: _body(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stage() {
    final double topInset = MediaQuery.of(context).padding.top;
    final LessonDetail? l = _lesson;

    Widget stageContainer = Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _buildStageContent(l),
          ),
          if (!_loading &&
              _error == null &&
              l != null &&
              l.hasAccess &&
              !l.locked &&
              !_inlineError &&
              _videoId != null &&
              _isStarted)
            Positioned.fill(
              child: _buildCustomControlsOverlay(),
            ),
          if (!_isFullscreen)
            Positioned(
              top: topInset > 0 ? topInset * 0.3 : 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _GlassButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    // Hardened mobile security: Intercept long-press above AbsorbPointer to block OS context menus & selection handles
    stageContainer = GestureDetector(
      onLongPress: () {
        debugPrint(
            '🛡️ [VideoPlayerScreen]: Long-press gesture blocked by security shield.');
      },
      behavior: HitTestBehavior.opaque,
      child: stageContainer,
    );

    if (_isFullscreen) {
      return Expanded(child: stageContainer);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: stageContainer,
    );
  }

  Widget _buildCustomControlsOverlay() {
    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    // onDoubleTap: () => _seekRelative(-10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    // onDoubleTap: () => _seekRelative(10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
          if (_showSeekFeedbackLeft)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.replay_10_rounded,
                        color: Colors.white, size: 24),
                    SizedBox(width: 6),
                    Text(
                      '-10s',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          if (_showSeekFeedbackRight)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '+10s',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.forward_10_rounded,
                        color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            // _seekRelative(-10);
                          },
                          icon: const Icon(Icons.replay_10_rounded,
                              color: Colors.white, size: 34),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          // onTap: _togglePlayPause,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.signalRed,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.signalRed
                                      .withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: () {
                            // _seekRelative(10);
                          },
                          icon: const Icon(Icons.forward_10_rounded,
                              color: Colors.white, size: 34),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              _formatDuration(_currentPositionSec),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 3.0,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 6.0),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 12.0),
                                  activeTrackColor: AppColors.signalRed,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: AppColors.signalRed,
                                ),
                                child: Slider(
                                  value: _currentPositionSec.clamp(
                                      0.0,
                                      _totalDurationSec > 0
                                          ? _totalDurationSec
                                          : 1.0),
                                  max: _totalDurationSec > 0
                                      ? _totalDurationSec
                                      : 1.0,
                                  onChanged: (double val) {
                                    setState(() {
                                      _currentPositionSec = val;
                                    });
                                  },
                                  onChangeEnd: (double val) {
                                    // _ytController?.seekTo(
                                    //     seconds: val, allowSeekAhead: true);
                                    _resetControlsTimer();
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDurationSec),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _toggleFullscreen,
                              child: Icon(
                                _isFullscreen
                                    ? Icons.fullscreen_exit_rounded
                                    : Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isBuffering)
            const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.signalRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageContent(LessonDetail? l) {
    if (_loading) {
      return const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: HatchPainter(
                colorA: Color(0xFF11182B),
                colorB: Color(0xFF0E1424),
                band: 12,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Initializing lesson player…',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      );
    }

    if (_error != null || l == null) {
      return Container(
        color: const Color(0xFF0E1424),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded,
                size: 32, color: AppColors.signalRed),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Couldn\'t load lesson',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    if (!l.hasAccess || l.locked) {
      return Container(
        color: const Color(0xFF0E1424),
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lock_outline_rounded, size: 36, color: Colors.amber),
            SizedBox(height: 8),
            Text(
              'This lesson is locked.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Purchase this course to unlock video access.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final VideoSource? source = _videoSource;
    if (source == null || !source.isValid) {
      return Container(
        color: const Color(0xFF0E1424),
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.video_library_outlined, size: 36, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'No video available.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    if (_inlineError) {
      return Container(
        color: const Color(0xFF0E1424),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.security_outlined,
                size: 36, color: AppColors.signalRed),
            const SizedBox(height: 10),
            const Text(
              'Protected Video Stream Unavailable',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'This video is restricted or cannot be embedded. Link sharing is blocked to protect course content.',
              style: TextStyle(
                  color: Colors.white70, fontSize: 11.5, height: 1.35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _retryPlayer,
              icon: const Icon(Icons.refresh_rounded,
                  size: 16, color: Colors.white),
              label: const Text('Retry Stream',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    if (_videoId != null) {
      return VideoPlayer(key: ValueKey(_videoId!), url: _videoId!);
      // if (!_isStarted) {
      //   return _buildPlayerPoster(l, source.videoId ?? '');
      // }
      // return Stack(
      //   children: <Widget>[
      //     // 1. Cropped & Shielded YouTube Player (Scale 1.15 hides top title bar & bottom "Watch on YouTube" button)
      //     Positioned.fill(
      //       child: ClipRect(
      //         child: Transform.scale(
      //           scale: 1.15,
      //           child: AbsorbPointer(
      //             absorbing: true,
      //             child: YoutubePlayer(
      //               controller: _ytController!,
      //               aspectRatio: 16 / 9,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     // 2. Anti-Piracy / Enterprise Security Watermark Overlay
      //     Positioned(
      //       top: 10,
      //       right: 14,
      //       child: IgnorePointer(
      //         child: Container(
      //           padding:
      //               const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      //           decoration: BoxDecoration(
      //             color: Colors.black.withValues(alpha: 0.55),
      //             borderRadius: BorderRadius.circular(4),
      //             border: Border.all(color: Colors.white24, width: 0.8),
      //           ),
      //           child: Row(
      //             mainAxisSize: MainAxisSize.min,
      //             children: <Widget>[
      //               Icon(Icons.shield_outlined,
      //                   color: Colors.white.withValues(alpha: 0.8), size: 11),
      //               const SizedBox(width: 4),
      //               Text(
      //                 'G-TEC PROTECTED CONTENT',
      //                 style: TextStyle(
      //                   color: Colors.white.withValues(alpha: 0.85),
      //                   fontSize: 9,
      //                   fontWeight: FontWeight.w700,
      //                   letterSpacing: 0.6,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // );
    }

    return const SizedBox.shrink();
  }



  Widget _body() {
    if (_loading) {
      return const LoadingIndicator(message: 'Loading lesson details…');
    }
    if (_error != null || _lesson == null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn\'t load lesson',
        message: _error ?? 'Please try again.',
        actionLabel: 'Retry',
        onAction: _load,
      );
    }

    final LessonDetail l = _lesson!;
    final String title = l.title.isNotEmpty ? l.title : (_argTitle ?? 'Lesson');

    final String? eyebrow = _subjectName == null
        ? null
        : (_chapterName == null
            ? _subjectName!.toUpperCase()
            : '${_subjectName!} · ${_chapterName!}'.toUpperCase());

    final List<String> metaParts = <String>[
      if ((l.durationSeconds ?? 0) > 0)
        '${(l.durationSeconds! / 60).round()} min',
      if (l.isFreePreview) 'Free preview',
      if (!l.hasAccess || l.locked) 'Locked' else 'Unlocked',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      children: <Widget>[
        if (eyebrow != null) ...<Widget>[
          Text(eyebrow,
              style: AppTextStyles.overline.copyWith(
                  fontSize: 11, letterSpacing: 1, color: AppColors.navy)),
          const SizedBox(height: 6),
        ],
        Text(title,
            style: AppTextStyles.titleSm.copyWith(fontSize: 19, height: 1.25)),
        if (metaParts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(metaParts.join(' · '),
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted)),
        ],
        const SizedBox(height: 16),
        _buildNextPrevNavigation(),
        const SizedBox(height: 16),
        _Tabs(
          labels: _tabs,
          selected: _tab,
          onChanged: (int i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 18),
        if (l.description != null &&
            l.description!.trim().isNotEmpty) ...<Widget>[
          Text(
            l.description!,
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: Color(0xFF5A6273)),
          ),
          const SizedBox(height: 20),
        ],
        Text('Downloadable materials',
            style: AppTextStyles.cardTitle
                .copyWith(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ..._materials(l),
      ],
    );
  }

  Widget _buildNextPrevNavigation() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _prevLessonId != null
                ? () => _switchLesson(_prevLessonId!, title: _prevLessonTitle)
                : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(
              _prevLessonTitle ?? 'Previous Lesson',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              side: const BorderSide(color: AppColors.borderSoft),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _nextLessonId != null
                ? () => _switchLesson(_nextLessonId!, title: _nextLessonTitle)
                : null,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              _nextLessonTitle ?? 'Next Lesson',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _materials(LessonDetail l) {
    if (l.resources.isEmpty) {
      return <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderSoft, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            l.hasAccess
                ? 'No downloadable materials for this lesson.'
                : 'Purchase this course to access notes and resources.',
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.muted),
          ),
        ),
      ];
    }

    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < l.resources.length; i++) {
      final ResourceItem r = l.resources[i];
      final List<String> parts = <String>[
        if (r.sizeLabel.isNotEmpty) r.sizeLabel,
        if (r.pageCount != null && r.pageCount! > 0) '${r.pageCount} pages',
      ];
      rows.add(_MaterialRow(
        title: r.title,
        meta: parts.isEmpty ? _typeLabel(r.type) : parts.join(' · '),
        onTap: () => _openResource(r),
      ));
      if (i != l.resources.length - 1) rows.add(const SizedBox(height: 10));
    }
    return rows;
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'PYQ':
        return 'Previous year questions';
      case 'RESOURCE':
        return 'Resource';
      case 'NOTE':
      default:
        return 'Notes';
    }
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Color(0xFFEFF2F6), width: 1.5)),
      ),
      child: Row(
        children: List<Widget>.generate(labels.length, (int i) {
          final bool active = i == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: Padding(
              padding: EdgeInsets.fromLTRB(i == 0 ? 2 : 12, 0, 12, 11),
              child: Container(
                decoration: active
                    ? const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: AppColors.navy, width: 2.5)),
                      )
                    : null,
                padding: const EdgeInsets.only(bottom: 0),
                child: Text(labels[i],
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                        color: active ? AppColors.navy : AppColors.muted)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSoft, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.redBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.description_outlined,
                  size: 18, color: AppColors.signalRed),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 13.5)),
                  if (meta.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 1),
                    Text(meta,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.file_download_outlined,
                  size: 17, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
