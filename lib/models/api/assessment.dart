import '../../core/utils/json.dart';

/// Assessment list item — GET /assessments.
class AssessmentListItem {
  const AssessmentListItem({
    required this.id,
    required this.type,
    required this.title,
    this.durationMinutes,
    required this.questionCount,
    required this.hasAccess,
    this.bestScore,
    this.totalMarks,
  });

  final String id;
  final String type; // MOCK_TEST | PYQ | ASSIGNMENT | PRACTICE_QUIZ
  final String title;
  final int? durationMinutes;
  final int questionCount;
  final bool hasAccess;
  final int? bestScore;
  final int? totalMarks;

  factory AssessmentListItem.fromJson(Map<String, dynamic> json) {
    return AssessmentListItem(
      id: Json.str(json['id']),
      type: Json.str(json['type'], 'MOCK_TEST'),
      title: Json.str(json['title']),
      durationMinutes: Json.intOrNull(json['durationMinutes']),
      questionCount: Json.intVal(json['questionCount']),
      hasAccess: Json.boolVal(json['hasAccess']),
      bestScore: Json.intOrNull(json['bestScore']),
      totalMarks: Json.intOrNull(json['totalMarks']),
    );
  }
}

/// Attemptable assessment — GET /assessments/:id (no correct answers leaked).
class AssessmentDetail {
  const AssessmentDetail({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.durationMinutes,
    required this.totalMarks,
    required this.questions,
  });

  final String id;
  final String type;
  final String title;
  final String? description;
  final int? durationMinutes;
  final int totalMarks;
  final List<Question> questions;

  factory AssessmentDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentDetail(
      id: Json.str(json['id']),
      type: Json.str(json['type'], 'MOCK_TEST'),
      title: Json.str(json['title']),
      description: Json.strOrNull(json['description']),
      durationMinutes: Json.intOrNull(json['durationMinutes']),
      totalMarks: Json.intVal(json['totalMarks']),
      questions: Json.list(json['questions']).map(Question.fromJson).toList(),
    );
  }
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    this.marks = 1,
  });

  final String id;
  final String text;
  final List<QuestionOption> options;
  final int marks;

  factory Question.fromJson(Map<String, dynamic> json) {
    // options is a JSON array [{id, text}].
    final opts = <QuestionOption>[];
    final raw = json['options'];
    if (raw is List) {
      for (final o in raw) {
        if (o is Map) {
          opts.add(QuestionOption.fromJson(Map<String, dynamic>.from(o)));
        }
      }
    }
    return Question(
      id: Json.str(json['id']),
      text: Json.str(json['text']),
      options: opts,
      marks: Json.intVal(json['marks'], 1),
    );
  }
}

class QuestionOption {
  const QuestionOption({required this.id, required this.text});
  final String id;
  final String text;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: Json.str(json['id']),
      text: Json.str(json['text']),
    );
  }
}

/// Auto-graded result — POST /assessments/:id/submit.
class AttemptResult {
  const AttemptResult({
    required this.attemptId,
    required this.score,
    required this.totalMarks,
    required this.correctCount,
    required this.questionCount,
    required this.percent,
    required this.review,
  });

  final String attemptId;
  final int score;
  final int totalMarks;
  final int correctCount;
  final int questionCount;
  final int percent;
  final List<QuestionReview> review;

  factory AttemptResult.fromJson(Map<String, dynamic> json) {
    return AttemptResult(
      attemptId: Json.str(json['attemptId']),
      score: Json.intVal(json['score']),
      totalMarks: Json.intVal(json['totalMarks']),
      correctCount: Json.intVal(json['correctCount']),
      questionCount: Json.intVal(json['questionCount']),
      percent: Json.intVal(json['percent']),
      review:
          Json.list(json['review']).map(QuestionReview.fromJson).toList(),
    );
  }
}

class QuestionReview {
  const QuestionReview({
    required this.questionId,
    this.yourAnswer,
    required this.correctOptionId,
    required this.isCorrect,
    this.marks = 1,
    this.explanation,
  });

  final String questionId;
  final String? yourAnswer;
  final String correctOptionId;
  final bool isCorrect;
  final int marks;
  final String? explanation;

  factory QuestionReview.fromJson(Map<String, dynamic> json) {
    return QuestionReview(
      questionId: Json.str(json['questionId']),
      yourAnswer: Json.strOrNull(json['yourAnswer']),
      correctOptionId: Json.str(json['correctOptionId']),
      isCorrect: Json.boolVal(json['isCorrect']),
      marks: Json.intVal(json['marks'], 1),
      explanation: Json.strOrNull(json['explanation']),
    );
  }
}

/// Attempt history row — GET /me/attempts.
class AttemptSummary {
  const AttemptSummary({
    required this.id,
    required this.assessmentId,
    this.assessmentTitle,
    this.assessmentType,
    this.score,
    this.totalMarks,
    this.correctCount,
    this.submittedAt,
  });

  final String id;
  final String assessmentId;
  final String? assessmentTitle;
  final String? assessmentType;
  final int? score;
  final int? totalMarks;
  final int? correctCount;
  final DateTime? submittedAt;

  int get percent {
    final t = totalMarks ?? 0;
    if (t <= 0) return 0;
    return (((score ?? 0) / t) * 100).round();
  }

  factory AttemptSummary.fromJson(Map<String, dynamic> json) {
    final a = Json.obj(json['assessment']);
    return AttemptSummary(
      id: Json.str(json['id']),
      assessmentId: Json.str(json['assessmentId']),
      assessmentTitle: Json.strOrNull(a['title']),
      assessmentType: Json.strOrNull(a['type']),
      score: Json.intOrNull(json['score']),
      totalMarks: Json.intOrNull(json['totalMarks']),
      correctCount: Json.intOrNull(json['correctCount']),
      submittedAt: Json.dateOrNull(json['submittedAt']),
    );
  }
}
