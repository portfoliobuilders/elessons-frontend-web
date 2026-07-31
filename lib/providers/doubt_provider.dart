import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/doubt.dart';
import '../repositories/doubt_repository.dart';
import 'view_status.dart';

/// Doubts / Q&A: ask, my list, per-lesson answered list, helpful votes.
class DoubtProvider extends ChangeNotifier {
  DoubtProvider(this._repo);
  final DoubtRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<Doubt> _mine = const [];
  List<Doubt> get mine => _mine;

  List<Doubt> _lessonDoubts = const [];
  List<Doubt> get lessonDoubts => _lessonDoubts;

  bool _submitting = false;
  bool get isSubmitting => _submitting;

  Future<void> loadMine() async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _mine = await _repo.myDoubts();
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadForLesson(String lessonId) async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      _lessonDoubts = await _repo.forLesson(lessonId);
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Returns null on success, or an error message.
  Future<String?> ask({required String lessonId, required String question}) async {
    _submitting = true;
    notifyListeners();
    try {
      final d = await _repo.ask(lessonId: lessonId, question: question);
      _mine = [d, ..._mine];
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Toggle a helpful vote. When [lessonId] is supplied the lesson thread is
  /// refreshed; otherwise the caller's own list is refreshed.
  Future<void> toggleHelpful(String doubtId, {String? lessonId}) async {
    try {
      await _repo.toggleHelpful(doubtId);
      if (lessonId != null) {
        await loadForLesson(lessonId);
      } else {
        await loadMine();
      }
    } on ApiException catch (_) {}
  }
}
