import '../../core/utils/json.dart';

/// A course row in "My Learnings" — GET /me/learnings.
class LearningCourse {
  const LearningCourse({
    required this.subjectId,
    required this.name,
    this.code,
    this.iconUrl,
    this.bannerUrl,
    required this.completedLessons,
    required this.totalLessons,
    required this.percent,
    required this.isComplete,
  });

  final String subjectId;
  final String name;
  final String? code;
  final String? iconUrl;
  final String? bannerUrl;
  final int completedLessons;
  final int totalLessons;
  final int percent;
  final bool isComplete;

  String get monogram {
    if (code != null && code!.trim().isNotEmpty) {
      return code!.substring(0, code!.length >= 3 ? 3 : code!.length).toUpperCase();
    }
    return name.replaceAll(RegExp(r'[^A-Za-z]'), '').padRight(3, 'X').substring(0, 3).toUpperCase();
  }

  factory LearningCourse.fromJson(Map<String, dynamic> json) {
    return LearningCourse(
      subjectId: Json.str(json['subjectId'] ?? json['id']),
      name: Json.str(json['name']),
      code: Json.strOrNull(json['code']),
      iconUrl: Json.strOrNull(json['iconUrl'] ?? json['imageUrl'] ?? json['icon']),
      bannerUrl: Json.strOrNull(json['bannerUrl'] ?? json['banner']),
      completedLessons: Json.intVal(json['completedLessons']),
      totalLessons: Json.intVal(json['totalLessons']),
      percent: Json.intVal(json['percent']),
      isComplete: Json.boolVal(json['isComplete']),
    );
  }
}

/// "Continue learning" card — GET /me/continue (nullable).
class ContinueLesson {
  const ContinueLesson({
    required this.lessonId,
    required this.title,
    required this.subject,
    required this.chapter,
    required this.watchedSeconds,
    this.durationSeconds,
  });

  final String lessonId;
  final String title;
  final String subject;
  final String chapter;
  final int watchedSeconds;
  final int? durationSeconds;

  double get progress {
    final d = durationSeconds ?? 0;
    if (d <= 0) return 0;
    return (watchedSeconds / d).clamp(0, 1).toDouble();
  }

  factory ContinueLesson.fromJson(Map<String, dynamic> json) {
    return ContinueLesson(
      lessonId: Json.str(json['lessonId']),
      title: Json.str(json['title']),
      subject: Json.str(json['subject']),
      chapter: Json.str(json['chapter']),
      watchedSeconds: Json.intVal(json['watchedSeconds']),
      durationSeconds: Json.intOrNull(json['durationSeconds']),
    );
  }
}

/// Profile stats — GET /me/stats `{ courses, avgProgress, dayStreak }`.
class ProgressStats {
  const ProgressStats({
    required this.courses,
    required this.avgProgress,
    required this.dayStreak,
  });

  final int courses;
  final int avgProgress;
  final int dayStreak;

  static const ProgressStats zero =
      ProgressStats(courses: 0, avgProgress: 0, dayStreak: 0);

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      courses: Json.intVal(json['courses']),
      avgProgress: Json.intVal(json['avgProgress']),
      dayStreak: Json.intVal(json['dayStreak']),
    );
  }
}
