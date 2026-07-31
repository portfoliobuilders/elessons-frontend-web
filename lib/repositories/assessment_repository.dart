import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/assessment.dart';

/// Assessments (assessments.controller.ts) — list, attempt, submit, history.
class AssessmentRepository {
  AssessmentRepository(this._api);
  final ApiClient _api;

  Future<List<AssessmentListItem>> list({
    String? subjectId,
    String? chapterId,
    String? type,
  }) async {
    final res = await _api.get(ApiEndpoints.assessments, query: {
      if (subjectId != null) 'subjectId': subjectId,
      if (chapterId != null) 'chapterId': chapterId,
      if (type != null) 'type': type,
    });
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(AssessmentListItem.fromJson)
        .toList();
  }

  Future<AssessmentDetail> getForAttempt(String id) async {
    final res = await _api.get(ApiEndpoints.assessment(id));
    return AssessmentDetail.fromJson(res as Map<String, dynamic>);
  }

  Future<AttemptResult> submit(String id, Map<String, String> answers) async {
    final res =
        await _api.post(ApiEndpoints.assessmentSubmit(id), body: {'answers': answers});
    return AttemptResult.fromJson(res as Map<String, dynamic>);
  }

  Future<List<AttemptSummary>> myAttempts() async {
    final res = await _api.get(ApiEndpoints.myAttempts);
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(AttemptSummary.fromJson)
        .toList();
  }
}
