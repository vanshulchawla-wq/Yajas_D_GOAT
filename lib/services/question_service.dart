import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../data/question_bank.dart';

class QuestionService {
  static const _remoteUrl = 'https://raw.githubusercontent.com/vanshulchawla-wq/Yajas_D_GOAT/main/questions.json';

  /// Get all questions for a subject+chapter+difficulty, excluding mastered ones
  static Future<List<Question>> getQuestions({required String subject, required String chapter, Difficulty? difficulty, bool excludeMastered = true}) async {
    var all = getLocalQuestions(subject: subject, chapter: chapter);
    // Try loading remote questions
    final remote = await _loadRemote();
    if (remote.isNotEmpty) {
      all.addAll(remote.where((q) => q.subject == subject && q.chapter == chapter));
    }
    if (difficulty != null) all = all.where((q) => q.difficulty == difficulty).toList();
    if (excludeMastered) {
      final mastered = await getMasteredIds();
      all = all.where((q) => !mastered.contains(q.id)).toList();
    }
    all.shuffle();
    return all;
  }

  /// Mark questions as mastered (answered correctly 3+ times)
  static Future<void> markMastered(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = prefs.getString('mastery_counts') ?? '{}';
    final map = Map<String, int>.from(jsonDecode(counts));
    map[questionId] = (map[questionId] ?? 0) + 1;
    await prefs.setString('mastery_counts', jsonEncode(map));
  }

  static Future<Set<String>> getMasteredIds() async {
    final prefs = await SharedPreferences.getInstance();
    final counts = prefs.getString('mastery_counts') ?? '{}';
    final map = Map<String, int>.from(jsonDecode(counts));
    return map.entries.where((e) => e.value >= 3).map((e) => e.key).toSet();
  }

  /// Bookmarked (wrong answers to revisit)
  static Future<void> bookmarkQuestion(Question q) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bookmarks') ?? [];
    if (!list.any((s) => jsonDecode(s)['id'] == q.id)) {
      list.add(jsonEncode(q.toJson()));
      await prefs.setStringList('bookmarks', list);
    }
  }

  static Future<void> removeBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bookmarks') ?? [];
    list.removeWhere((s) => jsonDecode(s)['id'] == id);
    await prefs.setStringList('bookmarks', list);
  }

  static Future<List<Question>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bookmarks') ?? [];
    return list.map((s) => Question.fromJson(jsonDecode(s))).toList();
  }

  /// Save/load test results
  static Future<void> saveResult(TestResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('results') ?? [];
    list.add(jsonEncode(result.toJson()));
    await prefs.setStringList('results', list);
    // Auto-mark mastered for correct answers
    for (final a in result.answers) {
      if (a.isCorrect) await markMastered(a.questionId);
    }
    // Auto-bookmark wrong answers
    for (final a in result.answers) {
      if (!a.isCorrect) {
        await bookmarkQuestion(Question(id: a.questionId, text: a.questionText, options: a.options, correctIndex: a.correctIndex, difficulty: result.difficulty, subject: result.subject, chapter: result.chapter));
      }
    }
  }

  static Future<List<TestResult>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('results') ?? [];
    final results = list.map((s) => TestResult.fromJson(jsonDecode(s))).toList();
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  /// Load remote questions (cached for 24h)
  static Future<List<Question>> _loadRemote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('remote_questions');
      final lastFetch = prefs.getInt('remote_fetch_time') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Use cache if less than 24h old
      if (cached != null && (now - lastFetch) < 86400000) {
        final list = jsonDecode(cached) as List;
        return list.map((j) => Question.fromJson(j)).toList();
      }
      final res = await http.get(Uri.parse(_remoteUrl)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        await prefs.setString('remote_questions', res.body);
        await prefs.setInt('remote_fetch_time', now);
        return list.map((j) => Question.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Stats
  static Future<Map<String, dynamic>> getStats() async {
    final results = await getResults();
    final mastered = await getMasteredIds();
    final bookmarks = await getBookmarks();
    final totalQuestions = allLocalQuestions.length;
    return {
      'totalTests': results.length,
      'totalPoints': results.fold(0, (sum, r) => sum + r.score),
      'avgScore': results.isEmpty ? 0.0 : results.fold(0.0, (sum, r) => sum + r.percentage) / results.length,
      'mastered': mastered.length,
      'totalQuestions': totalQuestions,
      'bookmarks': bookmarks.length,
      'streak': _calcStreak(results),
    };
  }

  static int _calcStreak(List<TestResult> results) {
    if (results.isEmpty) return 0;
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final dayStr = '${day.year}-${day.month}-${day.day}';
      if (results.any((r) => '${r.date.year}-${r.date.month}-${r.date.day}' == dayStr)) {
        streak++;
      } else if (i > 0) break;
    }
    return streak;
  }
}
