import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/playback.dart';

/// Video playback (video.controller.ts). Access is enforced server-side by
/// LessonAccessGuard; a 403 means "not purchased".
class VideoRepository {
  VideoRepository(this._api);
  final ApiClient _api;

  Future<Playback> playback(String lessonId) async {
    print('*** GET /api/lessons/$lessonId/playback - Exact ID being requested: $lessonId ***');
    final res = await _api.get(ApiEndpoints.playback(lessonId));
    final pb = Playback.fromJson(res as Map<String, dynamic>);
    print('*** GET /api/lessons/$lessonId/playback - RESPONSE youtubeId: ${pb.youtubeId} ***');
    return pb;
  }
}
