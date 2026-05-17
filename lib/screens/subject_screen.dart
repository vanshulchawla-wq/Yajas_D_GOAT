import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'test_screen.dart';

class SubjectScreen extends StatelessWidget {
  final Map<String, dynamic> subject;
  const SubjectScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final chapters = (subject['chapters'] as List?) ?? [];
    final color = Color(subject['color'] ?? 0xFF1565C0);
    return Scaffold(
      appBar: AppBar(title: Text(subject['name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), backgroundColor: color),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapters.length,
        itemBuilder: (_, i) {
          final ch = chapters[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('${i + 1}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: color)))),
              title: Text(ch['name'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('${ch['count'] ?? 0} questions', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
              children: [
                Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(children: [
                  _diffBtn(context, ch['name'], 'easy', '🟢 Easy', Colors.green, color),
                  _diffBtn(context, ch['name'], 'medium', '🟡 Medium', Colors.orange, color),
                  _diffBtn(context, ch['name'], 'hard', '🔴 Hard', Colors.red, color),
                  _diffBtn(context, ch['name'], null, '📝 All (Mock Test)', color, color),
                ])),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _diffBtn(BuildContext context, String chapter, String? diff, String label, Color labelColor, Color subjectColor) => GestureDetector(
    onTap: () async {
      final questions = await ApiService.getQuestions(subject: subject['name'], chapter: chapter, difficulty: diff, limit: 15);
      if (questions.isEmpty) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No questions available')));
        return;
      }
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TestScreen(
          questions: questions.map((q) => q.toJson()).toList(),
          title: '$chapter (${diff ?? "all"})',
          subject: subject['name'], chapter: chapter, difficulty: diff ?? 'medium',
        )));
      }
    },
    child: Container(
      width: double.infinity, margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: labelColor.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: labelColor.withOpacity(0.3))),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: labelColor))),
        Icon(Icons.play_arrow_rounded, color: labelColor, size: 20),
      ]),
    ),
  );
}
