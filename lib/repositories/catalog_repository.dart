import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/catalog.dart';

/// Catalog browsing (catalog.controller.ts). Grades/subjects/chapters are
/// public; lesson detail is fetched authed so gated fields resolve.
class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<List<Grade>> grades({String? board}) async {
    final res = await _api.get(ApiEndpoints.grades,
        query: {if (board != null) 'board': board}, auth: false);
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(Grade.fromJson)
        .toList();
  }

  Future<Grade> grade(String id) async {
    final res = await _api.get(ApiEndpoints.grade(id), auth: false);
    return Grade.fromJson(res as Map<String, dynamic>);
  }

  Future<SubjectModel> subject(String id) async {
    final res = await _api.get(ApiEndpoints.subject(id), auth: false);
    return SubjectModel.fromJson(res as Map<String, dynamic>);
  }

  Future<Chapter> chapter(String id) async {
    final res = await _api.get(ApiEndpoints.chapter(id), auth: false);
    return Chapter.fromJson(res as Map<String, dynamic>);
  }

  Future<LessonDetail> lesson(String id) async {
    print('*** GET /api/lessons/$id - Exact ID being requested: $id ***');
    final res = await _api.get(ApiEndpoints.lesson(id));
    final lessonDetail = LessonDetail.fromJson(res as Map<String, dynamic>);
    print('*** GET /api/lessons/$id - RESPONSE youtubeId: ${lessonDetail.youtubeId} | effectiveYoutubeId: ${lessonDetail.effectiveYoutubeId} ***');
    return lessonDetail;
  }
}
