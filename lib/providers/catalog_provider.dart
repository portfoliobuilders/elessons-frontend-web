import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/catalog.dart';
import '../repositories/catalog_repository.dart';
import 'view_status.dart';

/// Catalog browsing state: grades list + per-entity detail caches. Serves the
/// Store, Course Detail, By-Module and Curriculum screens.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repo);
  final CatalogRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<Grade> _grades = const [];
  List<Grade> get grades => _grades;

  final Map<String, Grade> _gradeDetail = {};
  final Map<String, SubjectModel> _subjectDetail = {};
  final Map<String, Chapter> _chapterDetail = {};

  Grade? gradeById(String id) => _gradeDetail[id];
  SubjectModel? subjectById(String id) => _subjectDetail[id];
  Chapter? chapterById(String id) => _chapterDetail[id];

  /// Wipes all in-memory catalog detail maps and grades list.
  void clearCache() {
    _grades = const [];
    _gradeDetail.clear();
    _subjectDetail.clear();
    _chapterDetail.clear();
    _status = ViewStatus.idle;
    _error = null;
    notifyListeners();
  }

  Future<void> loadGrades({String board = 'CBSE'}) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _grades = await _repo.grades(board: board);
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<Grade?> loadGrade(String id) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final g = await _repo.grade(id);
      _gradeDetail[id] = g;
      _status = ViewStatus.success;
      notifyListeners();
      return g;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<SubjectModel?> loadSubject(String id) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final s = await _repo.subject(id);
      _subjectDetail[id] = s;
      _status = ViewStatus.success;
      notifyListeners();
      return s;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<Chapter?> loadChapter(String id) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final c = await _repo.chapter(id);
      _chapterDetail[id] = c;
      _status = ViewStatus.success;
      notifyListeners();
      return c;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<LessonDetail?> loadLesson(String id) async {
    try {
      return await _repo.lesson(id);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }
}
