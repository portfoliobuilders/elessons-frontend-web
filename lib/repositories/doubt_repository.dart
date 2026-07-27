import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/api/doubt.dart';

/// Doubts / Q&A (doubts.controller.ts).
class DoubtRepository {
  DoubtRepository(this._api);
  final ApiClient _api;

  Future<Doubt> ask({required String lessonId, required String question}) async {
    final res = await _api.post(ApiEndpoints.doubts,
        body: {'lessonId': lessonId, 'question': question});
    return Doubt.fromJson(res as Map<String, dynamic>);
  }

  Future<List<Doubt>> myDoubts() async {
    final res = await _api.get(ApiEndpoints.myDoubts);
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(Doubt.fromJson)
        .toList();
  }

  Future<List<Doubt>> forLesson(String lessonId) async {
    final res = await _api.get(ApiEndpoints.lessonDoubts(lessonId));
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(Doubt.fromJson)
        .toList();
  }

  /// Returns the new helpful count after toggling.
  Future<int> toggleHelpful(String doubtId) async {
    final res = await _api.post(ApiEndpoints.doubtHelpful(doubtId));
    return Json.intVal(Json.obj(res)['helpfulCount']);
  }
}
