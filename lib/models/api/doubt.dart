import '../../core/utils/json.dart';

/// A doubt/Q&A item — GET /me/doubts, GET /lessons/:id/doubts.
class Doubt {
  const Doubt({
    required this.id,
    required this.question,
    this.answer,
    required this.status,
    this.lessonTitle,
    this.teacherName,
    this.studentName,
    this.helpfulCount = 0,
    this.createdAt,
    this.answeredAt,
  });

  final String id;
  final String question;
  final String? answer;
  final String status; // OPEN | ANSWERED | CLOSED
  final String? lessonTitle;
  final String? teacherName;
  final String? studentName;
  final int helpfulCount;
  final DateTime? createdAt;
  final DateTime? answeredAt;

  bool get isAnswered => status == 'ANSWERED';

  factory Doubt.fromJson(Map<String, dynamic> json) {
    final count = Json.obj(json['_count']);
    return Doubt(
      id: Json.str(json['id']),
      question: Json.str(json['question']),
      answer: Json.strOrNull(json['answer']),
      status: Json.str(json['status'], 'OPEN'),
      lessonTitle: Json.strOrNull(Json.obj(json['lesson'])['title']),
      teacherName: Json.strOrNull(Json.obj(json['teacher'])['name']),
      studentName: Json.strOrNull(Json.obj(json['student'])['name']),
      helpfulCount: Json.intVal(count['helpful']),
      createdAt: Json.dateOrNull(json['createdAt']),
      answeredAt: Json.dateOrNull(json['answeredAt']),
    );
  }
}
