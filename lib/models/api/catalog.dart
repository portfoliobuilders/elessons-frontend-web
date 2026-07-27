import '../../core/utils/json.dart';
import '../../core/utils/youtube_utils.dart';
import 'product.dart';

/// Grade — `GET /grades` (list) and `GET /grades/:id` (detail with subjects+products).
class Grade {
  const Grade({
    required this.id,
    required this.name,
    required this.board,
    this.syllabus,
    this.order = 0,
    this.isActive = true,
    this.subjects = const [],
    this.products = const [],
  });

  final String id;
  final String name; // "Class 10"
  final String board; // "CBSE"
  final String? syllabus;
  final int order;
  final bool isActive;
  final List<SubjectModel> subjects;
  final List<Product> products;

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      board: Json.str(json['board'], 'CBSE'),
      syllabus: Json.strOrNull(json['syllabus']),
      order: Json.intVal(json['order']),
      isActive: Json.boolVal(json['isActive'], true),
      subjects: Json.list(json['subjects']).map(SubjectModel.fromJson).toList(),
      products: Json.list(json['products']).map(Product.fromJson).toList(),
    );
  }
}

/// Subject — nested in grade detail (with `_count.chapters`) or full via
/// `GET /subjects/:id` (with chapters + products).
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.gradeId,
    this.teacherName,
    this.iconUrl,
    this.order = 0,
    this.chapterCount = 0,
    this.lessonCount = 0,
    this.chapters = const [],
    this.products = const [],
  });

  final String id;
  final String name;
  final String? code;
  final String? gradeId;
  final String? teacherName;
  final String? iconUrl;
  final int order;
  final int chapterCount;
  final int lessonCount;
  final List<Chapter> chapters;
  final List<Product> products;

  /// 3-letter monogram used by the hatch tiles (e.g. "SCI").
  String get monogram {
    if (code != null && code!.trim().isNotEmpty) {
      return code!
          .substring(0, code!.length >= 3 ? 3 : code!.length)
          .toUpperCase();
    }
    return name
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .padRight(3, 'X')
        .substring(0, 3)
        .toUpperCase();
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final count = Json.obj(json['_count']);
    final chapters = Json.list(json['chapters']).map(Chapter.fromJson).toList();
    return SubjectModel(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      code: Json.strOrNull(json['code']),
      gradeId: Json.strOrNull(json['gradeId']),
      teacherName: Json.strOrNull(json['teacherName']),
      iconUrl: Json.strOrNull(json['iconUrl']),
      order: Json.intVal(json['order']),
      chapterCount: Json.intOrNull(count['chapters']) ?? chapters.length,
      lessonCount: chapters.fold(0, (s, c) => s + c.lessonCount),
      chapters: chapters,
      products: Json.list(json['products']).map(Product.fromJson).toList(),
    );
  }
}

/// Chapter — nested in subject detail (with `_count.lessons`) or full via
/// `GET /chapters/:id` (with published lesson summaries + products).
class Chapter {
  const Chapter({
    required this.id,
    required this.name,
    this.subjectId,
    this.order = 0,
    this.lessonCount = 0,
    this.lessons = const [],
    this.products = const [],
  });

  final String id;
  final String name;
  final String? subjectId;
  final int order;
  final int lessonCount;
  final List<LessonSummary> lessons;
  final List<Product> products;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final count = Json.obj(json['_count']);
    final lessons =
        Json.list(json['lessons']).map(LessonSummary.fromJson).toList();
    return Chapter(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      subjectId: Json.strOrNull(json['subjectId']),
      order: Json.intVal(json['order']),
      lessonCount: Json.intOrNull(count['lessons']) ?? lessons.length,
      lessons: lessons,
      products: Json.list(json['products']).map(Product.fromJson).toList(),
    );
  }
}

/// Lightweight lesson row shown inside a chapter/curriculum.
class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.title,
    this.durationSeconds,
    this.order = 0,
    this.isFreePreview = false,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final int? durationSeconds;
  final int order;
  final bool isFreePreview;
  final String? thumbnailUrl;

  String get durationLabel {
    final s = durationSeconds ?? 0;
    if (s <= 0) return '—';
    final m = (s / 60).round();
    return '$m min';
  }

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    return LessonSummary(
      id: Json.str(json['id']),
      title: Json.str(json['title']),
      durationSeconds: Json.intOrNull(json['durationSeconds']),
      order: Json.intVal(json['order']),
      isFreePreview: Json.boolVal(json['isFreePreview']),
      thumbnailUrl: Json.strOrNull(json['thumbnailUrl']),
    );
  }
}

/// Full lesson detail — `GET /lessons/:id` (gated fields resolved server-side).
class LessonDetail {
  const LessonDetail({
    required this.id,
    required this.title,
    this.description,
    this.durationSeconds,
    this.thumbnailUrl,
    this.isFreePreview = false,
    this.hasAccess = false,
    this.youtubeId,
    this.videoUrl,
    this.resources = const [],
    this.locked = true,
  });

  final String id;
  final String title;
  final String? description;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final bool isFreePreview;
  final bool hasAccess;
  final String? youtubeId;
  final String? videoUrl;
  final List<ResourceItem> resources;
  final bool locked;

  /// Returns the extracted 11-character YouTube Video ID from [youtubeId], [videoUrl], or [thumbnailUrl].
  String? get effectiveYoutubeId =>
      extractYouTubeId(youtubeId) ??
      extractYouTubeId(videoUrl) ??
      extractYouTubeId(thumbnailUrl);

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    final String? rawYoutubeId = Json.strOrNull(json['youtubeId']);
    final String? rawVideoUrl = Json.strOrNull(json['videoUrl']) ??
        Json.strOrNull(json['youtubeUrl']) ??
        Json.strOrNull(json['video_url']) ??
        Json.strOrNull(json['url']);

    return LessonDetail(
      id: Json.str(json['id']),
      title: Json.str(json['title']),
      description: Json.strOrNull(json['description']),
      durationSeconds: Json.intOrNull(json['durationSeconds']),
      thumbnailUrl: Json.strOrNull(json['thumbnailUrl']),
      isFreePreview: Json.boolVal(json['isFreePreview']),
      hasAccess: Json.boolVal(json['hasAccess']),
      youtubeId: rawYoutubeId,
      videoUrl: rawVideoUrl ??
          (rawYoutubeId != null
              ? 'https://www.youtube.com/watch?v=$rawYoutubeId'
              : null),
      resources:
          Json.list(json['resources']).map(ResourceItem.fromJson).toList(),
      locked: Json.boolVal(json['locked'], true),
    );
  }
}

/// A downloadable resource (NOTE / PYQ / RESOURCE).
class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.type,
    required this.title,
    required this.fileKey,
    this.sizeBytes,
    this.pageCount,
    this.isDownloadable = true,
  });

  final String id;
  final String type;
  final String title;
  final String fileKey;
  final int? sizeBytes;
  final int? pageCount;
  final bool isDownloadable;

  String get sizeLabel {
    final b = sizeBytes ?? 0;
    if (b <= 0) return '';
    final mb = b / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(b / 1024).round()} KB';
  }

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: Json.str(json['id']),
      type: Json.str(json['type'], 'NOTE'),
      title: Json.str(json['title']),
      fileKey: Json.str(json['fileKey']),
      sizeBytes: Json.intOrNull(json['sizeBytes']),
      pageCount: Json.intOrNull(json['pageCount']),
      isDownloadable: Json.boolVal(json['isDownloadable'], true),
    );
  }
}
