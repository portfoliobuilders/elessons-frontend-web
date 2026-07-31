import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/catalog.dart';
import '../models/api/learning.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/progress_repository.dart';
import 'view_status.dart';

/// Aggregates the Home dashboard: the student's grade (subjects), the
/// "Continue learning" card and progress stats.
class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required CatalogRepository catalogRepository,
    required ProgressRepository progressRepository,
  })  : _catalog = catalogRepository,
        _progress = progressRepository;

  final CatalogRepository _catalog;
  final ProgressRepository _progress;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  Grade? _grade;
  Grade? get grade => _grade;
  List<SubjectModel> _subjects = const [];
  List<SubjectModel> get subjects => _subjects;

  ContinueLesson? _continue;
  ContinueLesson? get continueLesson => _continue;

  ProgressStats _stats = ProgressStats.zero;
  ProgressStats get stats => _stats;

  bool _loaded = false;
  bool get loaded => _loaded;

  /// Clear in-memory home cache.
  void clearCache() {
    _grade = null;
    _subjects = const [];
    _continue = null;
    _stats = ProgressStats.zero;
    _loaded = false;
    _status = ViewStatus.idle;
    _error = null;
    notifyListeners();
  }

  /// [gradeId] comes from the signed-in student's profile. When null we fall
  /// back to the first active grade so the Home tab still shows content.
  Future<void> load({String? gradeId, bool force = false}) async {
    if (_loaded && !force) return;
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      String? resolvedGradeId = gradeId;
      if (resolvedGradeId == null) {
        final grades = await _catalog.grades(board: 'CBSE');
        if (grades.isNotEmpty) resolvedGradeId = grades.first.id;
      }
      if (resolvedGradeId != null) {
        _grade = await _catalog.grade(resolvedGradeId);
        // Grade-detail subjects only carry chapter counts. Enrich each with its
        // detail (chapters → lesson counts, and subject-level products/prices)
        // in parallel so the Home/Store cards show accurate meta + "from ₹…".
        final base = _grade?.subjects ?? const <SubjectModel>[];
        final enriched = await Future.wait(base.map((s) async {
          try {
            return await _catalog.subject(s.id);
          } catch (_) {
            return s; // fall back to the lean version on any failure
          }
        }));
        _subjects = enriched;
      }
      // Learning widgets are best-effort — a new student has none yet.
      try {
        _continue = await _progress.continueLearning();
        _stats = await _progress.stats();
      } on ApiException catch (_) {}
      _status = ViewStatus.success;
      _loaded = true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh({String? gradeId}) async {
    _loaded = false;
    return load(gradeId: gradeId, force: true);
  }
}
