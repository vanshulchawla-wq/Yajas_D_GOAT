import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class TestScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String title, subject, chapter, difficulty;
  const TestScreen({super.key, required this.questions, required this.title, required this.subject, required this.chapter, required this.difficulty});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _current = 0;
  Map<int, int> _answers = {};
  bool _submitted = false;
  Map<String, dynamic>? _result;
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (!_submitted) setState(() => _elapsed++); });
  }

  void _select(int idx) { if (!_submitted) { HapticFeedback.lightImpact(); setState(() => _answers[_current] = idx); } }

  Future<void> _submit() async {
    _timer?.cancel();
    final answers = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.questions.length; i++) {
      answers.add({'question_id': widget.questions[i]['id'] ?? '', 'selected_index': _answers[i]});
    }
    final result = await ApiService.submitTest(subject: widget.subject, chapter: widget.chapter, difficulty: widget.difficulty, answers: answers, timeTaken: _elapsed);
    setState(() { _submitted = true; _result = result; });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_submitted && _result != null) return _buildResult();
    final q = widget.questions[_current];
    final options = List<String>.from(q['options'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('⏱ ${_elapsed ~/ 60}:${(_elapsed % 60).toString().padLeft(2, '0')}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70))))],
      ),
      body: Column(children: [
        LinearProgressIndicator(value: (_current + 1) / widget.questions.length, color: const Color(0xFF1565C0), backgroundColor: const Color(0xFF1565C0).withOpacity(0.1)),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Q${_current + 1}/${widget.questions.length}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1565C0)))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _diffColor(q['difficulty']).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text((q['difficulty'] ?? 'medium').toString().toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _diffColor(q['difficulty'])))),
          ]),
          const SizedBox(height: 20),
          Text(q['text'] ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4)),
          const SizedBox(height: 24),
          ...options.asMap().entries.map((e) {
            final selected = _answers[_current] == e.key;
            return GestureDetector(
              onTap: () => _select(e.key),
              child: Container(
                width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: selected ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? const Color(0xFF1565C0) : Colors.black12, width: selected ? 2 : 1)),
                child: Row(children: [
                  Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? const Color(0xFF1565C0) : Colors.grey.withOpacity(0.1)),
                    child: Center(child: Text(String.fromCharCode(65 + e.key), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : Colors.black54)))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.value, style: GoogleFonts.poppins(fontSize: 14, color: selected ? const Color(0xFF1565C0) : Colors.black87))),
                ]),
              ),
            );
          }),
        ]))),
        Container(padding: const EdgeInsets.all(16), color: Colors.white, child: Row(children: [
          if (_current > 0) OutlinedButton(onPressed: () => setState(() => _current--), child: const Text('Previous')),
          const Spacer(),
          if (_current < widget.questions.length - 1)
            ElevatedButton(onPressed: () => setState(() => _current++), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)), child: const Text('Next', style: TextStyle(color: Colors.white)))
          else
            ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        ])),
      ]),
    );
  }

  Widget _buildResult() {
    final score = _result!['score'] ?? 0;
    final total = _result!['total'] ?? 1;
    final pct = _result!['percentage'] ?? 0;
    final answers = (_result!['answers'] as List?) ?? [];

    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 20),
        Icon(pct >= 70 ? Icons.emoji_events : pct >= 40 ? Icons.thumb_up : Icons.refresh, size: 60, color: pct >= 70 ? Colors.amber : pct >= 40 ? Colors.orange : Colors.red),
        const SizedBox(height: 16),
        Text(pct >= 70 ? 'Excellent! 🎉' : pct >= 40 ? 'Good effort! 👍' : 'Keep practicing! 💪', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1565C0), width: 6)),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${pct.toInt()}%', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0))),
            Text('$score/$total', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
          ]))),
        const SizedBox(height: 12),
        Text('Time: ${_elapsed ~/ 60}m ${_elapsed % 60}s', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45)),
        const SizedBox(height: 30),
        Text('Review', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...answers.asMap().entries.map((e) {
          final a = e.value;
          final correct = a['is_correct'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: correct ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: correct ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(correct ? Icons.check_circle : Icons.cancel, size: 16, color: correct ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('Q${e.key + 1}: ${a['question_text'] ?? ''}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
              if (!correct) ...[
                const SizedBox(height: 4),
                Text('Your: ${a['selected_index'] != null ? (a['options'] as List)[a['selected_index']] : "Skipped"}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.red)),
                Text('Correct: ${(a['options'] as List)[a['correct_index']]}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
              ],
              if (a['explanation'] != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('💡 ${a['explanation']}', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54, fontStyle: FontStyle.italic))),
            ]),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), minimumSize: const Size(double.infinity, 48)),
          child: Text('Done', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600))),
      ]))),
    );
  }

  Color _diffColor(dynamic d) => d == 'easy' ? Colors.green : d == 'hard' ? Colors.red : Colors.orange;
}
