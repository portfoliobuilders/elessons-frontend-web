import 'package:flutter_test/flutter_test.dart';
import 'package:gtec_app/models/api/catalog.dart';

void main() {
  test('LessonDetail parses unique youtubeIds correctly per lesson response', () {
    final geoJson = {
      'id': 'lesson_geography_01',
      'title': 'Physical Geography of Earth',
      'youtubeId': 'cDf98hISlDA',
    };
    final histJson = {
      'id': 'lesson_history_01',
      'title': 'World War II Chronology',
      'youtubeId': 'H1jHdnZ2U3o',
    };
    final csJson = {
      'id': 'lesson_cs_01',
      'title': 'Data Structures & Algorithms',
      'youtubeId': 'Tzl0ELY_TiM',
    };

    final geoLesson = LessonDetail.fromJson(geoJson);
    final histLesson = LessonDetail.fromJson(histJson);
    final csLesson = LessonDetail.fromJson(csJson);

    expect(geoLesson.id, equals('lesson_geography_01'));
    expect(geoLesson.effectiveYoutubeId, equals('cDf98hISlDA'));

    expect(histLesson.id, equals('lesson_history_01'));
    expect(histLesson.effectiveYoutubeId, equals('H1jHdnZ2U3o'));

    expect(csLesson.id, equals('lesson_cs_01'));
    expect(csLesson.effectiveYoutubeId, equals('Tzl0ELY_TiM'));

    // Verify all three subjects receive 100% distinct YouTube IDs
    final ids = {
      geoLesson.effectiveYoutubeId,
      histLesson.effectiveYoutubeId,
      csLesson.effectiveYoutubeId,
    };
    expect(ids.length, equals(3));
  });
}
