import 'package:flutter/foundation.dart';
import '../models/api/learning_models.dart';
import '../repositories/learning_repository.dart';
import 'view_status.dart';

enum LearningSortFilter {
  recentlyViewed,
  recentlyPurchased,
  highestProgress,
  alphabetical,
}

class LearningProvider extends ChangeNotifier {
  LearningProvider(this._repository);

  final LearningRepository _repository;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;

  String? _error;
  String? get error => _error;

  List<SubjectModel> _allSubjects = [];
  List<SubjectModel> get allSubjects => _allSubjects;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  LearningSortFilter _activeFilter = LearningSortFilter.recentlyViewed;
  LearningSortFilter get activeFilter => _activeFilter;

  // Selected subject context
  SubjectModel? _selectedSubject;
  SubjectModel? get selectedSubject => _selectedSubject;

  List<ModuleModel> _selectedModules = [];
  List<ModuleModel> get selectedModules => _selectedModules;

  LessonModel? _activeLesson;
  LessonModel? get activeLesson => _activeLesson;

  CertificateModel? _activeCertificate;
  CertificateModel? get activeCertificate => _activeCertificate;

  /// Get in-progress subjects filtered & sorted
  List<SubjectModel> get inProgressSubjects {
    return _applyFilterAndSearch(_allSubjects.where((s) => !s.isCompleted).toList());
  }

  /// Get completed subjects filtered & sorted
  List<SubjectModel> get completedSubjects {
    return _applyFilterAndSearch(_allSubjects.where((s) => s.isCompleted).toList());
  }

  /// Overall stats
  int get totalEnrolledCourses => _allSubjects.length;

  int get averageProgress {
    if (_allSubjects.isEmpty) return 0;
    final total = _allSubjects.fold<int>(0, (sum, s) => sum + s.progressPercent);
    return (total / _allSubjects.length).round();
  }

  /// Wipes all in-memory learning subjects and selection state.
  void clearCache() {
    _allSubjects = [];
    _selectedSubject = null;
    _selectedModules = [];
    _activeLesson = null;
    _activeCertificate = null;
    _status = ViewStatus.idle;
    _error = null;
    notifyListeners();
  }

  Future<void> loadLearnings({bool force = false}) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _allSubjects = await _repository.getEnrolledSubjects();
      _status = ViewStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(LearningSortFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  List<SubjectModel> _applyFilterAndSearch(List<SubjectModel> list) {
    var filtered = list;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.teacherName.toLowerCase().contains(q) ||
              (s.code != null && s.code!.toLowerCase().contains(q)))
          .toList();
    }

    switch (_activeFilter) {
      case LearningSortFilter.highestProgress:
        filtered.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
        break;
      case LearningSortFilter.alphabetical:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case LearningSortFilter.recentlyPurchased:
      case LearningSortFilter.recentlyViewed:
        // default ordering
        break;
    }
    return filtered;
  }

  /// Load modules for a specific subject
  Future<void> loadSubjectModules(String subjectId) async {
    _selectedSubject = null;
    _selectedModules = [];
    _activeLesson = null;
    notifyListeners();

    try {
      _selectedSubject = _allSubjects.firstWhere((s) => s.id == subjectId);
    } catch (_) {
      _selectedSubject = SubjectModel(
        id: subjectId,
        name: 'Loading Subject...',
        teacherName: '',
        totalModules: 0,
        completedModules: 0,
        totalLessons: 0,
        completedLessons: 0,
        progressPercent: 0,
        isCompleted: false,
      );
    }
    _selectedModules = await _repository.getSubjectModules(subjectId);
    if (_selectedSubject != null && _selectedSubject!.name == 'Loading Subject...' && _selectedModules.isNotEmpty) {
       // Just to have something better if it loaded from API
       _selectedSubject = _selectedSubject!.copyWith(name: 'Subject Overview');
    }
    notifyListeners();
  }

  void setActiveLesson(LessonModel lesson) {
    _activeLesson = lesson;
    notifyListeners();
  }

  /// Mark lesson complete and trigger progress cascade:
  /// Lesson -> Module -> Subject -> Completed Tab movement when 100%!
  Future<void> markLessonComplete({
    required String subjectId,
    required String moduleId,
    required String lessonId,
  }) async {
    if (_selectedSubject == null) return;

    List<ModuleModel> updatedModules = [];
    int totalCompletedLessonsInSubject = 0;
    int totalLessonsInSubject = 0;
    int totalCompletedModules = 0;

    for (var mod in _selectedModules) {
      List<LessonModel> updatedLessons = [];
      int completedInMod = 0;

      for (var les in mod.lessons) {
        if (les.id == lessonId || (mod.id == moduleId && les.id == lessonId)) {
          final updated = les.copyWith(
            isCompleted: true,
            watchedSeconds: les.durationMinutes * 60,
          );
          updatedLessons.add(updated);
          if (_activeLesson?.id == lessonId) {
            _activeLesson = updated;
          }
        } else {
          updatedLessons.add(les);
        }
      }

      completedInMod = updatedLessons.where((l) => l.isCompleted).length;
      final isModCompleted =
          updatedLessons.isNotEmpty && completedInMod == updatedLessons.length;
      if (isModCompleted) totalCompletedModules++;

      totalCompletedLessonsInSubject += completedInMod;
      totalLessonsInSubject += mod.lessons.isNotEmpty ? mod.lessons.length : mod.totalLessons;

      updatedModules.add(mod.copyWith(
        completedLessons: completedInMod,
        isCompleted: isModCompleted,
        lessons: updatedLessons,
      ));
    }

    _selectedModules = updatedModules;

    final totalLesCount = totalLessonsInSubject > 0
        ? totalLessonsInSubject
        : (_selectedSubject!.totalLessons > 0 ? _selectedSubject!.totalLessons : 1);

    final newCompletedLesCount = totalCompletedLessonsInSubject > 0
        ? totalCompletedLessonsInSubject
        : (_selectedSubject!.completedLessons + 1);

    final newPercent = ((newCompletedLesCount / totalLesCount) * 100).round().clamp(0, 100);
    final isSubjectFinished = newPercent >= 100;

    final updatedSubject = _selectedSubject!.copyWith(
      completedLessons: newCompletedLesCount,
      completedModules: totalCompletedModules,
      progressPercent: newPercent,
      isCompleted: isSubjectFinished,
      completionDate: isSubjectFinished ? DateTime.now() : null,
    );

    _selectedSubject = updatedSubject;

    final idx = _allSubjects.indexWhere((s) => s.id == subjectId);
    if (idx != -1) {
      _allSubjects[idx] = updatedSubject;
    }

    notifyListeners();

    _repository.updateLessonProgress(
      subjectId: subjectId,
      moduleId: moduleId,
      lessonId: lessonId,
      watchedSeconds: (_activeLesson?.durationMinutes ?? 15) * 60,
      isCompleted: true,
    );
  }

  Future<CertificateModel> fetchCertificate(String subjectId, String studentName) async {
    _activeCertificate = await _repository.getCertificate(subjectId, studentName);
    notifyListeners();
    return _activeCertificate!;
  }
}
