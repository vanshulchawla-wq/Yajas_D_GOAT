enum Difficulty { easy, medium, hard }

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final Difficulty difficulty;
  final String? explanation;
  final String subject;
  final String chapter;
  Question({required this.id, required this.text, required this.options, required this.correctIndex, required this.difficulty, this.explanation, required this.subject, required this.chapter});

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'options': options, 'correctIndex': correctIndex, 'difficulty': difficulty.name, 'explanation': explanation, 'subject': subject, 'chapter': chapter};
  factory Question.fromJson(Map<String, dynamic> j) => Question(
    id: j['id'] ?? '', text: j['text'], options: List<String>.from(j['options']),
    correctIndex: j['correctIndex'], difficulty: Difficulty.values.firstWhere((d) => d.name == (j['difficulty'] ?? 'medium')),
    explanation: j['explanation'], subject: j['subject'] ?? '', chapter: j['chapter'] ?? '',
  );
}

class TestResult {
  final String id;
  final String subject;
  final String chapter;
  final Difficulty difficulty;
  final int score;
  final int total;
  final DateTime date;
  final int timeTakenSecs;
  final List<AnswerRecord> answers;
  TestResult({required this.id, required this.subject, required this.chapter, required this.difficulty, required this.score, required this.total, required this.date, required this.timeTakenSecs, required this.answers});

  double get percentage => total > 0 ? (score / total) * 100 : 0;
  String get grade => percentage >= 90 ? 'A+' : percentage >= 80 ? 'A' : percentage >= 70 ? 'B' : percentage >= 60 ? 'C' : percentage >= 40 ? 'D' : 'F';

  Map<String, dynamic> toJson() => {'id': id, 'subject': subject, 'chapter': chapter, 'difficulty': difficulty.name, 'score': score, 'total': total, 'date': date.toIso8601String(), 'time': timeTakenSecs, 'answers': answers.map((a) => a.toJson()).toList()};
  factory TestResult.fromJson(Map<String, dynamic> j) => TestResult(
    id: j['id'] ?? '', subject: j['subject'], chapter: j['chapter'],
    difficulty: Difficulty.values.firstWhere((d) => d.name == j['difficulty']),
    score: j['score'], total: j['total'], date: DateTime.parse(j['date']), timeTakenSecs: j['time'] ?? 0,
    answers: ((j['answers'] as List?) ?? []).map((a) => AnswerRecord.fromJson(a)).toList(),
  );
}

class AnswerRecord {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final bool isCorrect;
  AnswerRecord({required this.questionId, required this.questionText, required this.options, required this.correctIndex, this.selectedIndex, required this.isCorrect});

  Map<String, dynamic> toJson() => {'qid': questionId, 'text': questionText, 'options': options, 'correct': correctIndex, 'selected': selectedIndex, 'isCorrect': isCorrect};
  factory AnswerRecord.fromJson(Map<String, dynamic> j) => AnswerRecord(
    questionId: j['qid'] ?? '', questionText: j['text'] ?? '', options: List<String>.from(j['options'] ?? []),
    correctIndex: j['correct'] ?? 0, selectedIndex: j['selected'], isCorrect: j['isCorrect'] ?? false,
  );
}

class Subject {
  final String name;
  final String icon;
  final int color;
  final List<Chapter> chapters;
  Subject({required this.name, required this.icon, required this.color, required this.chapters});
}

class Chapter {
  final String name;
  final String subject;
  Chapter({required this.name, required this.subject});
}
