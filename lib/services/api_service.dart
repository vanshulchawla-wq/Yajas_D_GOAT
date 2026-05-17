import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const baseUrl = 'https://yajas-d-goat.onrender.com';
  static const userId = 'default';

  static Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/subjects')).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (_) {}
    return [];
  }

  static Future<List<Question>> getQuestions({required String subject, required String chapter, String? difficulty, int limit = 10}) async {
    try {
      var url = '$baseUrl/questions/$subject/$chapter?limit=$limit&user_id=$userId';
      if (difficulty != null) url += '&difficulty=$difficulty';
      final res = await http.get(Uri.parse(Uri.encodeFull(url))).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((j) => Question.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> submitTest({required String subject, required String chapter, required String difficulty, required List<Map<String, dynamic>> answers, required int timeTaken}) async {
    final res = await http.post(Uri.parse('$baseUrl/submit-test'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'subject': subject, 'chapter': chapter, 'difficulty': difficulty, 'answers': answers, 'time_taken': timeTaken}),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'ok': false, 'error': res.body};
  }

  static Future<List<Map<String, dynamic>>> getResults() async {
    final res = await http.get(Uri.parse('$baseUrl/results/$userId')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    return [];
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stats/$userId')).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {};
  }

  static Future<Map<String, dynamic>> getWeeklyTest() async {
    final res = await http.get(Uri.parse('$baseUrl/weekly-test?user_id=$userId')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {};
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final res = await http.get(Uri.parse('$baseUrl/bookmarks/$userId')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    return [];
  }

  static Future<void> removeBookmark(String questionId) async {
    await http.delete(Uri.parse('$baseUrl/bookmarks/$userId/$questionId')).timeout(const Duration(seconds: 10));
  }

  static Future<List<Map<String, dynamic>>> getPastPapers({String? subject, int? year}) async {
    try {
      var url = '$baseUrl/past-papers?';
      if (subject != null) url += 'subject=$subject&';
      if (year != null) url += 'year=$year&';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> getPastPaperYears() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/past-papers/years')).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {'years': [], 'subjects': []};
  }

  static Future<void> saveUploadedPaper({required String subject, required String title, required List<Map<String, dynamic>> questions}) async {
    await http.post(Uri.parse('$baseUrl/save-uploaded-paper'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'subject': subject, 'title': title, 'questions': questions}),
    ).timeout(const Duration(seconds: 15));
  }

  static Future<List<Map<String, dynamic>>> getUploadedPapers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/uploaded-papers/$userId')).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (_) {}
    return [];
  }
}
