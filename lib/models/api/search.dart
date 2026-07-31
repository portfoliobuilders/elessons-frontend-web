import '../../core/utils/json.dart';

/// Aggregated search results — GET /search?q=...
class SearchResults {
  const SearchResults({
    required this.query,
    this.subjects = const [],
    this.chapters = const [],
    this.lessons = const [],
    this.tests = const [],
  });

  final String query;
  final List<SearchSubject> subjects;
  final List<SearchChapter> chapters;
  final List<SearchLesson> lessons;
  final List<SearchTest> tests;

  int get total =>
      subjects.length + chapters.length + lessons.length + tests.length;
  bool get isEmpty => total == 0;

  static const SearchResults empty = SearchResults(query: '');

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      query: Json.str(json['query']),
      subjects:
          Json.list(json['subjects']).map(SearchSubject.fromJson).toList(),
      chapters:
          Json.list(json['chapters']).map(SearchChapter.fromJson).toList(),
      lessons: Json.list(json['lessons']).map(SearchLesson.fromJson).toList(),
      tests: Json.list(json['tests']).map(SearchTest.fromJson).toList(),
    );
  }
}

class SearchSubject {
  const SearchSubject({required this.id, required this.name, this.gradeName});
  final String id;
  final String name;
  final String? gradeName;

  factory SearchSubject.fromJson(Map<String, dynamic> json) => SearchSubject(
        id: Json.str(json['id']),
        name: Json.str(json['name']),
        gradeName: Json.strOrNull(Json.obj(json['grade'])['name']),
      );
}

class SearchChapter {
  const SearchChapter({required this.id, required this.name, this.subjectName});
  final String id;
  final String name;
  final String? subjectName;

  factory SearchChapter.fromJson(Map<String, dynamic> json) => SearchChapter(
        id: Json.str(json['id']),
        name: Json.str(json['name']),
        subjectName: Json.strOrNull(Json.obj(json['subject'])['name']),
      );
}

class SearchLesson {
  const SearchLesson({
    required this.id,
    required this.title,
    this.isFreePreview = false,
    this.chapterName,
    this.subjectName,
  });
  final String id;
  final String title;
  final bool isFreePreview;
  final String? chapterName;
  final String? subjectName;

  factory SearchLesson.fromJson(Map<String, dynamic> json) {
    final chapter = Json.obj(json['chapter']);
    return SearchLesson(
      id: Json.str(json['id']),
      title: Json.str(json['title']),
      isFreePreview: Json.boolVal(json['isFreePreview']),
      chapterName: Json.strOrNull(chapter['name']),
      subjectName: Json.strOrNull(Json.obj(chapter['subject'])['name']),
    );
  }
}

class SearchTest {
  const SearchTest({
    required this.id,
    required this.title,
    this.type,
    this.subjectName,
  });
  final String id;
  final String title;
  final String? type;
  final String? subjectName;

  factory SearchTest.fromJson(Map<String, dynamic> json) => SearchTest(
        id: Json.str(json['id']),
        title: Json.str(json['title']),
        type: Json.strOrNull(json['type']),
        subjectName: Json.strOrNull(Json.obj(json['subject'])['name']),
      );
}
