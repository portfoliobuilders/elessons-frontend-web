import '../../core/utils/json.dart';

/// Represents an active student subject enrollment.
class EnrollmentModel {
  const EnrollmentModel({
    required this.enrollmentId,
    required this.subjectId,
    required this.subjectName,
    this.subjectCode,
    this.bannerUrl,
    required this.enrolledAt,
    required this.isCompleted,
    required this.progressPercent,
  });

  final String enrollmentId;
  final String subjectId;
  final String subjectName;
  final String? subjectCode;
  final String? bannerUrl;
  final DateTime enrolledAt;
  final bool isCompleted;
  final int progressPercent;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      enrollmentId: Json.str(json['enrollmentId'] ?? json['id']),
      subjectId: Json.str(json['subjectId']),
      subjectName: Json.str(json['subjectName'] ?? json['name']),
      subjectCode: Json.strOrNull(json['subjectCode'] ?? json['code']),
      bannerUrl: Json.strOrNull(json['bannerUrl']),
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: Json.boolVal(json['isCompleted']),
      progressPercent: Json.intVal(json['progressPercent'] ?? json['percent']),
    );
  }
}

/// Detailed Subject model for My Learnings.
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.bannerUrl,
    required this.teacherName,
    this.teacherAvatarUrl,
    required this.totalModules,
    required this.completedModules,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.isCompleted,
    this.lastWatchedLessonTitle,
    this.lastWatchedLessonId,
    this.nextLessonTitle,
    this.nextLessonId,
    this.remainingMinutes,
    this.totalDurationMinutes,
    this.enrolledDate,
    this.completionDate,
  });

  final String id;
  final String name;
  final String? code;
  final String? bannerUrl;
  final String teacherName;
  final String? teacherAvatarUrl;
  final int totalModules;
  final int completedModules;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final bool isCompleted;
  final String? lastWatchedLessonTitle;
  final String? lastWatchedLessonId;
  final String? nextLessonTitle;
  final String? nextLessonId;
  final int? remainingMinutes;
  final int? totalDurationMinutes;
  final DateTime? enrolledDate;
  final DateTime? completionDate;

  String get monogram {
    if (code != null && code!.trim().isNotEmpty) {
      return code!.substring(0, code!.length >= 3 ? 3 : code!.length).toUpperCase();
    }
    return name.replaceAll(RegExp(r'[^A-Za-z]'), '').padRight(3, 'X').substring(0, 3).toUpperCase();
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: Json.str(json['id'] ?? json['subjectId']),
      name: Json.str(json['name']),
      code: Json.strOrNull(json['code']),
      bannerUrl: Json.strOrNull(json['bannerUrl'] ?? json['imageUrl']),
      teacherName: Json.str(json['teacherName'], 'Lead Instructor'),
      teacherAvatarUrl: Json.strOrNull(json['teacherAvatarUrl']),
      totalModules: Json.intVal(json['totalModules']),
      completedModules: Json.intVal(json['completedModules']),
      totalLessons: Json.intVal(json['totalLessons']),
      completedLessons: Json.intVal(json['completedLessons']),
      progressPercent: Json.intVal(json['progressPercent'] ?? json['percent']),
      isCompleted: Json.boolVal(json['isCompleted']),
      lastWatchedLessonTitle: Json.strOrNull(json['lastWatchedLessonTitle']),
      lastWatchedLessonId: Json.strOrNull(json['lastWatchedLessonId']),
      nextLessonTitle: Json.strOrNull(json['nextLessonTitle']),
      nextLessonId: Json.strOrNull(json['nextLessonId']),
      remainingMinutes: Json.intOrNull(json['remainingMinutes']),
      totalDurationMinutes: Json.intOrNull(json['totalDurationMinutes']),
      enrolledDate: json['enrolledDate'] != null
          ? DateTime.tryParse(json['enrolledDate'].toString())
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.tryParse(json['completionDate'].toString())
          : null,
    );
  }

  SubjectModel copyWith({
    String? name,
    int? completedModules,
    int? completedLessons,
    int? progressPercent,
    bool? isCompleted,
    String? lastWatchedLessonTitle,
    String? lastWatchedLessonId,
    String? nextLessonTitle,
    String? nextLessonId,
    int? remainingMinutes,
    DateTime? completionDate,
  }) {
    return SubjectModel(
      id: id,
      name: name ?? this.name,
      code: code,
      bannerUrl: bannerUrl,
      teacherName: teacherName,
      teacherAvatarUrl: teacherAvatarUrl,
      totalModules: totalModules,
      completedModules: completedModules ?? this.completedModules,
      totalLessons: totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      progressPercent: progressPercent ?? this.progressPercent,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatchedLessonTitle: lastWatchedLessonTitle ?? this.lastWatchedLessonTitle,
      lastWatchedLessonId: lastWatchedLessonId ?? this.lastWatchedLessonId,
      nextLessonTitle: nextLessonTitle ?? this.nextLessonTitle,
      nextLessonId: nextLessonId ?? this.nextLessonId,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      totalDurationMinutes: totalDurationMinutes,
      enrolledDate: enrolledDate,
      completionDate: completionDate ?? this.completionDate,
    );
  }
}

/// Module in a subject.
class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.subjectId,
    required this.moduleNumber,
    required this.title,
    required this.totalLessons,
    required this.completedLessons,
    required this.estimatedMinutes,
    required this.isLocked,
    required this.isCompleted,
    required this.lessons,
  });

  final String id;
  final String subjectId;
  final int moduleNumber;
  final String title;
  final int totalLessons;
  final int completedLessons;
  final int estimatedMinutes;
  final bool isLocked;
  final bool isCompleted;
  final List<LessonModel> lessons;

  int get progressPercent =>
      totalLessons == 0 ? 0 : ((completedLessons / totalLessons) * 100).round();

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = (json['lessons'] as List<dynamic>? ?? [])
        .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
        .toList();

    final parsedTotal = Json.intVal(json['totalLessons']);
    final totalLes = parsedTotal > 0 ? parsedTotal : rawLessons.length;

    final parsedEst = Json.intVal(json['estimatedMinutes']);
    final estMins = parsedEst > 0
        ? parsedEst
        : rawLessons.fold(0, (sum, l) => sum + l.durationMinutes);

    final completedCount = Json.intVal(json['completedLessons']);
    final actualCompleted = completedCount > 0
        ? completedCount
        : rawLessons.where((l) => l.isCompleted).length;

    return ModuleModel(
      id: Json.str(json['id']),
      subjectId: Json.str(json['subjectId']),
      moduleNumber: Json.intVal(json['moduleNumber'] ?? json['order'], 1),
      title: Json.str(json['title'] ?? json['name'], 'Module'),
      totalLessons: totalLes,
      completedLessons: actualCompleted,
      estimatedMinutes: estMins,
      isLocked: Json.boolVal(json['isLocked']),
      isCompleted: Json.boolVal(json['isCompleted']) || (totalLes > 0 && actualCompleted == totalLes),
      lessons: rawLessons,
    );
  }

  ModuleModel copyWith({
    int? completedLessons,
    bool? isLocked,
    bool? isCompleted,
    List<LessonModel>? lessons,
  }) {
    return ModuleModel(
      id: id,
      subjectId: subjectId,
      moduleNumber: moduleNumber,
      title: title,
      totalLessons: totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      estimatedMinutes: estimatedMinutes,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
      lessons: lessons ?? this.lessons,
    );
  }
}

/// Individual Lesson Model.
class LessonModel {
  const LessonModel({
    required this.id,
    required this.moduleId,
    required this.title,
    this.thumbnailUrl,
    required this.videoUrl,
    required this.durationMinutes,
    this.notesUrl,
    this.hasQuiz = false,
    this.hasAssignment = false,
    this.hasResources = false,
    this.watchedSeconds = 0,
    this.isCompleted = false,
    this.description,
  });

  final String id;
  final String moduleId;
  final String title;
  final String? thumbnailUrl;
  final String videoUrl;
  final int durationMinutes;
  final String? notesUrl;
  final bool hasQuiz;
  final bool hasAssignment;
  final bool hasResources;
  final int watchedSeconds;
  final bool isCompleted;
  final String? description;

  double get progressFraction {
    final totalSec = durationMinutes * 60;
    if (totalSec <= 0) return isCompleted ? 1.0 : 0.0;
    return (watchedSeconds / totalSec).clamp(0.0, 1.0);
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: Json.str(json['id']),
      moduleId: Json.str(json['moduleId']),
      title: Json.str(json['title']),
      thumbnailUrl: Json.strOrNull(json['thumbnailUrl']),
      videoUrl: Json.str(json['videoUrl'] ?? json['youtubeUrl'] ?? ''),
      durationMinutes: Json.intVal(json['durationMinutes'], 15),
      notesUrl: Json.strOrNull(json['notesUrl']),
      hasQuiz: Json.boolVal(json['hasQuiz']),
      hasAssignment: Json.boolVal(json['hasAssignment']),
      hasResources: Json.boolVal(json['hasResources']),
      watchedSeconds: Json.intVal(json['watchedSeconds']),
      isCompleted: Json.boolVal(json['isCompleted']),
      description: Json.strOrNull(json['description']),
    );
  }

  LessonModel copyWith({
    int? watchedSeconds,
    bool? isCompleted,
  }) {
    return LessonModel(
      id: id,
      moduleId: moduleId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      durationMinutes: durationMinutes,
      notesUrl: notesUrl,
      hasQuiz: hasQuiz,
      hasAssignment: hasAssignment,
      hasResources: hasResources,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description,
    );
  }
}

/// Certificate representation for completed subjects.
class CertificateModel {
  const CertificateModel({
    required this.certificateId,
    required this.subjectId,
    required this.subjectName,
    required this.studentName,
    required this.issuedDate,
    required this.downloadUrl,
    required this.verificationCode,
  });

  final String certificateId;
  final String subjectId;
  final String subjectName;
  final String studentName;
  final DateTime issuedDate;
  final String downloadUrl;
  final String verificationCode;

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      certificateId: Json.str(json['certificateId'] ?? json['id']),
      subjectId: Json.str(json['subjectId']),
      subjectName: Json.str(json['subjectName']),
      studentName: Json.str(json['studentName'], 'Student'),
      issuedDate: json['issuedDate'] != null
          ? DateTime.tryParse(json['issuedDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      downloadUrl: Json.str(json['downloadUrl']),
      verificationCode: Json.str(json['verificationCode'], 'GTEC-CERT-2026'),
    );
  }
}
