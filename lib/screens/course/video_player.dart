import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:screen_protector/screen_protector.dart';
import 'dart:async';

class VideoPlayer extends StatefulWidget {
  final String url;
  const VideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isVideoPlaying = false;
  double _currentVideoPosition = 0;
  double _videoDuration = 0;
  Timer? _positionTimer;
  String _currentQuality = 'auto';
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isInitialized = false;
  bool _isFullscreen = false;
  final FocusNode _focusNode = FocusNode();

  final int _skipDuration = 10;
  static const double _epsilon = 0.35; // Avoid exact end to prevent restart

  // Define available video qualities (UI only; actual change requires API support)
  final List<String> _qualities = [
    'auto',
    '144p',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p'
  ];

  // Check if device is mobile (phone/small tablet)
  bool get _isMobile {
    final data = MediaQuery.of(context);
    final shortestSide = data.size.shortestSide;
    // Consider devices with shortest side less than 600px as mobile
    return shortestSide < 600;
  }

  @override
  void initState() {
    super.initState();
    _enableScreenProtection();
    _initializePlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _positionTimer?.cancel();
      _hideControlsTimer?.cancel();
      try {
        _controller.close();
      } catch (_) {}
      _isInitialized = false;
      _currentVideoPosition = 0;
      _videoDuration = 0;
      _initializePlayer();
    }
  }

  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('Error enabling screen protection: $e');
    }
  }

  void _initializePlayer() {
    final videoId = YoutubePlayerController.convertUrlToId(widget.url);

    if (videoId == null) {
      debugPrint('Invalid YouTube URL');
      _showErrorDialog('Invalid video URL');
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: false,
        playsInline: true,
        strictRelatedVideos: true,
        enableCaption: false,
        // IMPORTANT: enableJavaScript true improves seek reliability
        enableJavaScript: true,
        // Block pointer interactions; we render our own controls
        pointerEvents: PointerEvents.none,
      ),
    );

    _controller.listen((event) async {
      if (!mounted) return;

      // Prefer metadata duration if present (more reliable)
      final md = event.metaData;
      final mdSeconds = md.duration.inSeconds.toDouble();
      if (mdSeconds > 0 &&
          (_videoDuration == 0 || (_videoDuration - mdSeconds).abs() > 0.5)) {
        setState(() => _videoDuration = mdSeconds);
      }

      switch (event.playerState) {
        case PlayerState.playing:
          setState(() {
            _isVideoPlaying = true;
            _isInitialized = true;
          });
          _startPositionTimer();
          _startHideControlsTimer();
          break;
        case PlayerState.paused:
          setState(() {
            _isVideoPlaying = false;
            _showControls = true;
          });
          _hideControlsTimer?.cancel();
          break;
        case PlayerState.ended:
          setState(() {
            _isVideoPlaying = false;
            _showControls = true;
          });
          _positionTimer?.cancel();
          _hideControlsTimer?.cancel();
          break;
        case PlayerState.unStarted:
          setState(() {
            _isInitialized = false;
          });
          break;
        default:
          break;
      }
    });

    _loadVideoData(); // fallback to controller.duration once player is ready
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FF00))),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVideoData() async {
    try {
      // Poll a few times until duration becomes available
      for (int i = 0; i < 10; i++) {
        final duration = await _controller.duration;
        if (duration > 0) {
          if (!mounted) return;
          setState(() {
            _videoDuration = duration.toDouble();
            _isInitialized = true;
          });
          break;
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Error loading video data: $e');
      _showErrorDialog('Failed to load video data');
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (mounted && _isVideoPlaying) {
        try {
          final position = await _controller.currentTime;
          if (mounted) {
            setState(() {
              _currentVideoPosition = position.toDouble();
            });
          }
        } catch (e) {
          debugPrint('Error getting position: $e');
        }
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isVideoPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _isVideoPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    if (_isVideoPlaying) {
      _startHideControlsTimer();
    }
  }

  // Handle keyboard events
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
          _toggleVideoPlayback();
          _showControlsTemporarily();
          break;
        case LogicalKeyboardKey.arrowRight:
          _skipForward();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _skipBackward();
          break;
        case LogicalKeyboardKey.escape:
          if (_isFullscreen) {
            _toggleFullscreen();
          }
          break;
        case LogicalKeyboardKey.keyF:
          _toggleFullscreen();
          break;
        case LogicalKeyboardKey.keyR:
          if (_isMobile) {
            _rotateScreen();
          }
          break;
      }
    }
  }

  Future<void> _toggleFullscreen() async {
    try {
      setState(() {
        _isFullscreen = !_isFullscreen;
      });

      if (_isFullscreen) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (e) {
      debugPrint('Error toggling fullscreen: $e');
    }
  }

  Future<void> _rotateScreen() async {
    try {
      final currentOrientation = MediaQuery.of(context).orientation;
      if (currentOrientation == Orientation.portrait) {
        // Switch to landscape
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        // Enter fullscreen mode when rotating to landscape
        setState(() {
          _isFullscreen = true;
        });
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        // Switch to portrait
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        // Exit fullscreen mode when rotating to portrait
        setState(() {
          _isFullscreen = false;
        });
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }

      // Show controls temporarily after rotation
      _showControlsTemporarily();
    } catch (e) {
      debugPrint('Error rotating screen: $e');
    }
  }

  String _formatDuration(double seconds) {
    final Duration duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleVideoPlayback() async {
    try {
      if (_isVideoPlaying) {
        await _controller.pauseVideo();
      } else {
        await _controller.playVideo();
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }

  Future<void> _skipForward() async {
    try {
      if (_videoDuration <= 0) return; // guard
      double safeEnd = (_videoDuration - _epsilon).clamp(0, _videoDuration);
      double newPosition = _currentVideoPosition + _skipDuration;
      if (newPosition >= safeEnd) {
        newPosition = safeEnd;
      }
      await _controller.seekTo(seconds: newPosition, allowSeekAhead: true);
      setState(() {
        _currentVideoPosition = newPosition;
      });
      _showControlsTemporarily();
    } catch (e) {
      debugPrint('Error skipping forward: $e');
    }
  }

  Future<void> _skipBackward() async {
    try {
      if (_videoDuration <= 0) return; // guard
      double newPosition = _currentVideoPosition - _skipDuration;
      if (newPosition < 0) newPosition = 0;
      await _controller.seekTo(seconds: newPosition, allowSeekAhead: true);
      setState(() {
        _currentVideoPosition = newPosition;
      });
      _showControlsTemporarily();
    } catch (e) {
      debugPrint('Error skipping backward: $e');
    }
  }

  Widget _buildVideoContainer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for control bar height (120px) and safe area padding
        final availableHeight = constraints.maxHeight - 120;
        final availableWidth = constraints.maxWidth;

        // Calculate optimal 16:9 aspect ratio that fits available space
        const targetAspect = 16.0 / 9.0;
        double videoWidth = availableWidth;
        double videoHeight = videoWidth / targetAspect;

        // If height exceeds available space, constrain by height
        if (videoHeight > availableHeight) {
          videoHeight = availableHeight;
          videoWidth = videoHeight * targetAspect;
        }

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Center(
            child: SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: targetAspect,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlsContainer() {
    final bool shouldShowControls = _showControls || !_isVideoPlaying;
    final double safeSliderMax = _videoDuration > 0
        ? (_videoDuration - _epsilon).clamp(0, _videoDuration)
        : 1.0;

    return AnimatedOpacity(
      opacity: shouldShowControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: 100, // Increased height for better spacing
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Duration text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentVideoPosition),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    _formatDuration(_videoDuration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Controls row
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Play/Pause
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          _toggleVideoPlayback();
                          _showControlsTemporarily();
                          // Ensure focus is maintained after button press
                          if (mounted) {
                            _focusNode.requestFocus();
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Progress bar
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF00FF41),
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: const Color(0xFF00FF41),
                          overlayColor:
                              const Color(0xFF00FF41).withOpacity(0.3),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8),
                          trackHeight: 4,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: _videoDuration > 0
                              ? _currentVideoPosition.clamp(0.0, safeSliderMax)
                              : 0.0,
                          min: 0.0,
                          max: safeSliderMax,
                          onChanged: (value) async {
                            if (_videoDuration <= 0) return;
                            final double safeTarget =
                                value.clamp(0.0, safeSliderMax);
                            setState(() {
                              _currentVideoPosition = safeTarget;
                            });
                            await _controller.seekTo(
                              seconds: safeTarget,
                              allowSeekAhead: true,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Skip backward 10s
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 20),
                        onPressed: _skipBackward,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Skip forward 10s
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 20),
                        onPressed: _skipForward,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8), // Bottom padding
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _hideControlsTimer?.cancel();
    try {
      _controller.close();
    } catch (_) {}
    _focusNode.dispose();

    _disableScreenProtection();

    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  Future<void> _disableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint('Error disabling screen protection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: MouseRegion(
          onHover: (event) => _showControlsTemporarily(),
          child: Stack(
            children: [
              // Video takes the full screen
              _buildVideoContainer(),

              // Transparent interaction layer above video
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _showControlsTemporarily();
                    // Ensure focus is maintained after tap
                    if (mounted) {
                      _focusNode.requestFocus();
                    }
                  },
                  onDoubleTap: () {
                    // Request focus on double tap too
                    if (mounted) {
                      _focusNode.requestFocus();
                    }
                  },
                  onLongPress: () {
                    // Request focus on long press too
                    if (mounted) {
                      _focusNode.requestFocus();
                    }
                  },
                  onSecondaryTap: () {
                    // Request focus on secondary tap too
                    if (mounted) {
                      _focusNode.requestFocus();
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Top overlay with back button and rotation button (mobile only)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: (_showControls || !_isVideoPlaying) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                            // Show rotate button only on mobile devices
                            if (_isMobile)
                              IconButton(
                                icon: const Icon(Icons.screen_rotation,
                                    color: Colors.white, size: 24),
                                onPressed: _rotateScreen,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Controls overlay at the bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: _buildControlsContainer(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on YoutubePlayerController {
  get videoQuality => null;
  setPlaybackQuality(String quality) {}
}
