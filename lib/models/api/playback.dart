import '../../core/utils/json.dart';

/// Video playback payload — GET /lessons/:id/playback (YouTube-backed).
class Playback {
  const Playback({
    required this.title,
    this.youtubeId,
    this.embedUrl,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  final String title;
  final String? youtubeId;
  final String? embedUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;

  factory Playback.fromJson(Map<String, dynamic> json) {
    return Playback(
      title: Json.str(json['title']),
      youtubeId: Json.strOrNull(json['youtubeId']),
      embedUrl: Json.strOrNull(json['embedUrl']),
      thumbnailUrl: Json.strOrNull(json['thumbnailUrl']),
      durationSeconds: Json.intOrNull(json['durationSeconds']),
    );
  }
}
