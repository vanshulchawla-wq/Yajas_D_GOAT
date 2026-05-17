import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'test_screen.dart';

class PastPapersScreen extends StatefulWidget {
  const PastPapersScreen({super.key});
  @override
  State<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends State<PastPapersScreen> {
  List<String> _years = [];
  List<String> _subjects = [];
  List<Map<String, dynamic>> _papers = [];
  String? _selectedSubject;
  String? _selectedYear;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final filters = await ApiService.getCbsePaperFilters();
    _years = List<String>.from(filters['years'] ?? []);
    _subjects = List<String>.from(filters['subjects'] ?? []);
    await _loadPapers();
  }

  Future<void> _loadPapers() async {
    final papers = await ApiService.getCbsePapers(subject: _selectedSubject, year: _selectedYear);
    if (mounted) setState(() { _papers = papers; _loading = false; });
  }

  void _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _startLiveTest(Map<String, dynamic> paper) {
    final questions = (paper['questions'] as List?)?.map((q) => Map<String, dynamic>.from(q)).toList() ?? [];
    if (questions.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => TestScreen(
      questions: questions,
      title: '${paper['subject']} ${paper['year']}',
      subject: paper['subject'] ?? '',
      chapter: 'Board Paper ${paper['year']}',
      difficulty: 'medium',
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CBSE Board Papers', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(12), color: Colors.white,
          child: Column(children: [
            SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('All Years', _selectedYear == null, () { _selectedYear = null; _loadPapers(); }),
              ..._years.map((y) => _chip(y, _selectedYear == y, () { _selectedYear = y; _loadPapers(); })),
            ])),
            const SizedBox(height: 8),
            SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('All Subjects', _selectedSubject == null, () { _selectedSubject = null; _loadPapers(); }),
              ..._subjects.map((s) => _chip(s, _selectedSubject == s, () { _selectedSubject = s; _loadPapers(); })),
            ])),
          ]),
        ),
        if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_papers.isEmpty) Expanded(child: Center(child: Text('No papers found', style: GoogleFonts.poppins(color: Colors.black45))))
        else Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _papers.length,
          itemBuilder: (_, i) {
            final p = _papers[i];
            final isMS = p['type'] == 'Marking Scheme';
            final hasLiveTest = p['has_live_test'] == true;
            final mcqCount = p['mcq_count'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasLiveTest ? Colors.green.withOpacity(0.4) : isMS ? Colors.orange.withOpacity(0.3) : const Color(0xFF1565C0).withOpacity(0.3))),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(
                  color: hasLiveTest ? Colors.green.withOpacity(0.1) : isMS ? Colors.orange.withOpacity(0.1) : const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                  child: Icon(hasLiveTest ? Icons.quiz : isMS ? Icons.check_circle_outline : Icons.picture_as_pdf,
                    color: hasLiveTest ? Colors.green : isMS ? Colors.orange : const Color(0xFF1565C0), size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${p['subject']} - ${p['year']}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(hasLiveTest ? '$mcqCount MCQs • Live Test' : '${p['type']} • PDF',
                    style: GoogleFonts.poppins(fontSize: 10, color: hasLiveTest ? Colors.green : Colors.black45)),
                ])),
                if (hasLiveTest)
                  ElevatedButton(
                    onPressed: () => _startLiveTest(p),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Take Test', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  )
                else
                  IconButton(icon: const Icon(Icons.open_in_new, size: 18, color: Colors.black38), onPressed: () => _openPdf(p['url'] ?? '')),
              ]),
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
          borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black54)),
      ),
    ),
  );
}
