import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/learning.dart';

/// Learning progress (progress.controller.ts).
class ProgressRepository {
  ProgressRepository(this._api);
  final ApiClient _api;

  Future<void> update({
    required String lessonId,
    required int watchedSeconds,
    bool? completed,
  }) async {
    await _api.post(ApiEndpoints.lessonProgress(lessonId), body: {
      'watchedSeconds': watchedSeconds,
      if (completed != null) 'completed': completed,
    });
  }

  Future<List<LearningCourse>> myLearnings({String? status}) async {
    final res = await _api.get(ApiEndpoints.myLearnings,
        query: {if (status != null) 'status': status});
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(LearningCourse.fromJson)
        .toList();
  }

  Future<ContinueLesson?> continueLearning() async {
    final res = await _api.get(ApiEndpoints.continueLearning);
    if (res == null || res is! Map<String, dynamic>) return null;
    return ContinueLesson.fromJson(res);
  }

  Future<ProgressStats> stats() async {
    final res = await _api.get(ApiEndpoints.myStats);
    return ProgressStats.fromJson(res as Map<String, dynamic>);
  }
}
