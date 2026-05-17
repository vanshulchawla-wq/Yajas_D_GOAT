import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'test_screen.dart';

class PastPapersScreen extends StatefulWidget {
  const PastPapersScreen({super.key});
  @override
  State<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends State<PastPapersScreen> {
  List<int> _years = [];
  List<String> _subjects = [];
  List<Map<String, dynamic>> _papers = [];
  String? _selectedSubject;
  int? _selectedYear;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final meta = await ApiService.getPastPaperYears();
    _years = List<int>.from(meta['years'] ?? []);
    _subjects = List<String>.from(meta['subjects'] ?? []);
    await _loadPapers();
  }

  Future<void> _loadPapers() async {
    final papers = await ApiService.getPastPapers(subject: _selectedSubject, year: _selectedYear);
    if (mounted) setState(() { _papers = papers; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Past Board Papers', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: Column(children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(12), color: Colors.white,
          child: Column(children: [
            // Year chips
            SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('All Years', _selectedYear == null, () { _selectedYear = null; _loadPapers(); }),
              ..._years.map((y) => _chip('$y', _selectedYear == y, () { _selectedYear = y; _loadPapers(); })),
            ])),
            const SizedBox(height: 8),
            // Subject chips
            SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('All Subjects', _selectedSubject == null, () { _selectedSubject = null; _loadPapers(); }),
              ..._subjects.map((s) => _chip(s, _selectedSubject == s, () { _selectedSubject = s; _loadPapers(); })),
            ])),
          ]),
        ),
        // Papers list
        if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_papers.isEmpty) Expanded(child: Center(child: Text('No papers found', style: GoogleFonts.poppins(color: Colors.black45))))
        else Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _papers.length,
          itemBuilder: (_, i) {
            final p = _papers[i];
            final questions = (p['questions'] as List?) ?? [];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TestScreen(
                questions: questions.map((q) => Map<String, dynamic>.from(q)).toList(),
                title: '${p['subject']} ${p['year']}',
                subject: p['subject'] ?? '', chapter: 'Board Exam ${p['year']}', difficulty: 'medium',
              ))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
                ),
                child: Row(children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('${p['year']}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0)))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${p['subject']}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('Board Exam Paper • ${questions.length} questions', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                  ])),
                  const Icon(Icons.play_circle_outline, color: Color(0xFF1565C0), size: 28),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: () => setState(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1565C0) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black54)),
      ),
    ),
  );
}
