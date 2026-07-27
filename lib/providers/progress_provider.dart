import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/learning.dart';
import '../repositories/progress_repository.dart';
import 'view_status.dart';

/// "My Learnings" list + continue card + stats + watch-progress reporting.
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repo);
  final ProgressRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<LearningCourse> _courses = const [];
  List<LearningCourse> get courses => _courses;

  ContinueLesson? _continue;
  ContinueLesson? get continueLesson => _continue;

  ProgressStats _stats = ProgressStats.zero;
  ProgressStats get stats => _stats;

  String? _filter; // null | in_progress | completed

  Future<void> loadLearnings({String? status, bool force = false}) async {
    _filter = status;
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _courses = await _repo.myLearnings(status: status);
      // Continue + stats fetched alongside for the header (best-effort).
      try {
        _continue = await _repo.continueLearning();
        _stats = await _repo.stats();
      } on ApiException catch (_) {}
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadLearnings(status: _filter, force: true);

  Future<void> loadStats() async {
    try {
      _stats = await _repo.stats();
      notifyListeners();
    } on ApiException catch (_) {}
  }

  /// Report watch progress from the video player (fire-and-forget friendly).
  Future<void> reportProgress({
    required String lessonId,
    required int watchedSeconds,
    bool? completed,
  }) async {
    try {
      await _repo.update(
        lessonId: lessonId,
        watchedSeconds: watchedSeconds,
        completed: completed,
      );
    } on ApiException catch (_) {/* swallow — non-critical telemetry */}
  }
}
