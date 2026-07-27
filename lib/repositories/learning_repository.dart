import 'package:flutter/foundation.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/api/learning_models.dart';

/// Repository for student learning, enrollments, modules, lessons, and certificates.
class LearningRepository {
  LearningRepository(this._api);
  final ApiClient _api;

  /// Fetch enrolled subjects from backend API or return sample enrolled subjects.
  Future<List<SubjectModel>> getEnrolledSubjects({String? filter}) async {
    try {
      final res = await _api.get(ApiEndpoints.myLearnings, query: {if (filter != null) 'status': filter});
      debugPrint('--- DEBUG: GET /me/learnings API RESPONSE ---');
      debugPrint(res.toString());
      if (res is List && res.isNotEmpty) {
        return res
            .whereType<Map<String, dynamic>>()
            .map((json) => SubjectModel.fromJson(json))
            .toList();
      }
    } catch (_) {}

    try {
      final res = await _api.get('/student/subjects');
      final rawList = res is Map ? (res['subjects'] as List?) : (res is List ? res : null);
      if (rawList != null && rawList.isNotEmpty) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((json) => SubjectModel.fromJson(json))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Get subject modules & lessons hierarchy.
  Future<List<ModuleModel>> getSubjectModules(String subjectId) async {
    try {
      final res = await _api.get(ApiEndpoints.subject(subjectId));
      debugPrint('--- DEBUG: GET /subjects/$subjectId API RESPONSE ---');
      debugPrint(res.toString());
      if (res is Map<String, dynamic>) {
        final chapters = res['chapters'] as List<dynamic>? ?? [];
        if (chapters.isNotEmpty) {
          final modules = <ModuleModel>[];
          for (var ch in chapters) {
            final chapterMap = ch as Map<String, dynamic>;
            final chId = Json.str(chapterMap['id']);

            var lessons = (chapterMap['lessons'] as List<dynamic>? ?? [])
                .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
                .toList();

            // If chapter lessons array from subject API is empty, attempt fetching GET /chapters/:id
            if (lessons.isEmpty && chId.isNotEmpty) {
              try {
                final chRes = await _api.get(ApiEndpoints.chapter(chId));
                if (chRes is Map<String, dynamic>) {
                  lessons = (chRes['lessons'] as List<dynamic>? ?? [])
                      .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
                      .toList();
                }
              } catch (_) {}
            }

            final totalCount = lessons.length;
            final completedCount = lessons.where((l) => l.isCompleted).length;
            final totalMins = lessons.fold(0, (sum, l) => sum + l.durationMinutes);

            modules.add(ModuleModel(
              id: chId.isEmpty ? 'mod_1' : chId,
              subjectId: subjectId,
              moduleNumber: Json.intVal(chapterMap['order'], modules.length + 1),
              title: Json.str(chapterMap['name'], 'Module ${modules.length + 1}'),
              totalLessons: totalCount,
              completedLessons: completedCount,
              estimatedMinutes: totalMins,
              isLocked: false,
              isCompleted: totalCount > 0 && completedCount == totalCount,
              lessons: lessons,
            ));
          }
          if (modules.isNotEmpty) return modules;
        }
      }
    } catch (_) {}

    return [];
  }

  Future<LessonModel?> getLesson(String lessonId) async {
    try {
      print('*** GET /api/lessons/$lessonId - Exact ID being requested: $lessonId ***');
      final res = await _api.get(ApiEndpoints.lesson(lessonId));
      if (res is Map<String, dynamic>) {
        final model = LessonModel.fromJson(res);
        print('*** GET /api/lessons/$lessonId - RESPONSE youtubeId: ${res['youtubeId']} | videoUrl: ${res['videoUrl']} ***');
        return model;
      }
    } catch (_) {}
    return null;
  }

  /// Update lesson completion telemetry.
  Future<void> updateLessonProgress({
    required String subjectId,
    required String moduleId,
    required String lessonId,
    required int watchedSeconds,
    required bool isCompleted,
  }) async {
    try {
      await _api.post(ApiEndpoints.lessonProgress(lessonId), body: {
        'watchedSeconds': watchedSeconds,
        'completed': isCompleted,
      });
    } catch (_) {
      try {
        await _api.patch('/student/progress', body: {
          'subjectId': subjectId,
          'moduleId': moduleId,
          'lessonId': lessonId,
          'watchedSeconds': watchedSeconds,
          'isCompleted': isCompleted,
        });
      } catch (_) {}
    }
  }

  /// Get Certificate details for a completed subject.
  Future<CertificateModel> getCertificate(String subjectId, String studentName) async {
    try {
      final res = await _api.get('/student/certificate/$subjectId');
      return CertificateModel.fromJson(res as Map<String, dynamic>);
    } catch (_) {}
    return CertificateModel(
      certificateId: 'CERT-${subjectId.toUpperCase()}-2026',
      subjectId: subjectId,
      subjectName: 'Enrolled Course',
      studentName: studentName.isEmpty ? 'Student' : studentName,
      issuedDate: DateTime.now(),
      downloadUrl: '',
      verificationCode: 'GTEC-VERIFIED-${subjectId.toUpperCase()}',
    );
  }
}
