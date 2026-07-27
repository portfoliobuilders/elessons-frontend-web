import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/assessment.dart';
import '../repositories/assessment_repository.dart';
import 'view_status.dart';

/// Assessments: list, load-for-attempt, submit (auto-grade), history.
class AssessmentProvider extends ChangeNotifier {
  AssessmentProvider(this._repo);
  final AssessmentRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<AssessmentListItem> _items = const [];
  List<AssessmentListItem> get items => _items;

  List<AttemptSummary> _attempts = const [];
  List<AttemptSummary> get attempts => _attempts;

  AssessmentDetail? _active;
  AssessmentDetail? get active => _active;

  AttemptResult? _lastResult;
  AttemptResult? get lastResult => _lastResult;

  Future<void> loadList(
      {String? subjectId, String? chapterId, String? type}) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.list(
          subjectId: subjectId, chapterId: chapterId, type: type);
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<AssessmentDetail?> loadForAttempt(String id) async {
    _status = ViewStatus.loading;
    _error = null;
    _active = null;
    notifyListeners();
    try {
      _active = await _repo.getForAttempt(id);
      _status = ViewStatus.success;
      notifyListeners();
      return _active;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<AttemptResult?> submit(String id, Map<String, String> answers) async {
    try {
      _lastResult = await _repo.submit(id, answers);
      notifyListeners();
      return _lastResult;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadAttempts() async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      _attempts = await _repo.myAttempts();
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }
}
