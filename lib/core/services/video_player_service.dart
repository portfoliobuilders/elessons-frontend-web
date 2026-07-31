import '../../models/api/catalog.dart';

/// Supported video source types for current and future video hosting engines.
enum VideoSourceType {
  youtube,
  ownedStorage, // Cloudflare R2, AWS S3, HLS (.m3u8), Direct MP4
  vimeo,
  unknown,
}

/// Abstract unified video source object for the player layer.
class VideoSource {
  const VideoSource({
    required this.type,
    this.videoId,
    this.streamUrl,
    this.rawUrl,
  });

  final VideoSourceType type;
  final String? videoId;
  final String? streamUrl;
  final String? rawUrl;

  bool get isValid =>
      (videoId != null && videoId!.isNotEmpty) ||
      (streamUrl != null && streamUrl!.isNotEmpty);

  @override
  String toString() =>
      'VideoSource(type: $type, videoId: ${videoId != null ? "...[PROTECTED]" : "null"}, isValid: $isValid)';
}

/// Abstract Video Player Service to decouple the UI from video storage providers.
class VideoPlayerService {
  VideoPlayerService._();

  /// Resolves a [VideoSource] from a [LessonDetail] model.
  static VideoSource resolveSource(LessonDetail? lesson) {
    if (lesson == null) {
      return const VideoSource(type: VideoSourceType.unknown);
    }

    // 1. Future-proof: Owned Cloudflare R2 / AWS S3 / HLS / MP4 Stream
    final String? vUrl = lesson.videoUrl;
    if (vUrl != null &&
        (vUrl.endsWith('.mp4') ||
            vUrl.endsWith('.m3u8') ||
            vUrl.contains('r2.cloudflarestorage.com') ||
            vUrl.contains('cloudfront.net') ||
            vUrl.contains('b-cdn.net'))) {
      return VideoSource(
        type: VideoSourceType.ownedStorage,
        streamUrl: vUrl,
        rawUrl: vUrl,
      );
    }

    // 2. YouTube Video (youtubeId or youtubeUrl)
    final String? ytId = lesson.effectiveYoutubeId;
    if (ytId != null && ytId.isNotEmpty && ytId.length == 11) {
      return VideoSource(
        type: VideoSourceType.youtube,
        videoId: ytId,
        rawUrl: vUrl,
      );
    }

    return const VideoSource(type: VideoSourceType.unknown);
  }
}
