import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'subject_screen.dart';
import 'test_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List<Map<String, dynamic>> _subjects = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final subjects = await ApiService.getSubjects();
      final stats = await ApiService.getStats();
      if (mounted) setState(() { _subjects = subjects; _stats = stats; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? const Center(child: CircularProgressIndicator()) : [_buildHome(), _buildSubjects(), const HistoryScreen(), const StatsScreen()][_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.analytics_rounded), label: 'Stats'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final streak = _stats['streak'] ?? 0;
    final mastered = _stats['mastered'] ?? 0;
    final totalQ = _stats['total_questions'] ?? 0;
    final avgScore = (_stats['avg_score'] ?? 0).toDouble();
    final totalTests = _stats['total_tests'] ?? 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/avatar.jpeg', width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 44))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YCExamPrep', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
              Text('CBSE Board Preparation', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
            ])),
            IconButton(icon: const Icon(Icons.bookmark_rounded, color: Color(0xFF1565C0)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
          ]),
          const SizedBox(height: 20),
          // Stats row
          Row(children: [
            _statCard('🔥', '$streak', 'Day Streak', const Color(0xFFFFF3E0)),
            const SizedBox(width: 10),
            _statCard('✅', '$mastered/$totalQ', 'Mastered', const Color(0xFFE8F5E9)),
            const SizedBox(width: 10),
            _statCard('📊', '${avgScore.toInt()}%', 'Average', const Color(0xFFE3F2FD)),
            const SizedBox(width: 10),
            _statCard('📝', '$totalTests', 'Tests', const Color(0xFFF3E5F5)),
          ]),
          const SizedBox(height: 24),
          // Weekly Test
          GestureDetector(
            onTap: _startWeeklyTest,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
                borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Text('📋', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Weekly Test', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Mixed subjects • New every week', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                ])),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          // Quick access subjects
          Text('Quick Start', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._subjects.take(5).map((s) => _subjectTile(s)),
        ])),
      ),
    );
  }

  Widget _buildSubjects() {
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Text('All Subjects', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700))),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _subjects.length,
        itemBuilder: (_, i) => _subjectTile(_subjects[i]),
      )),
    ]));
  }

  Widget _subjectTile(Map<String, dynamic> s) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectScreen(subject: s))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: Color(s['color'] ?? 0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(s['icon'] ?? '📚', style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s['name'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          Text('${(s['chapters'] as List?)?.length ?? 0} chapters • ${s['totalQuestions'] ?? 0} questions', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
        ])),
        Icon(Icons.chevron_right, color: Color(s['color'] ?? 0xFF1565C0)),
      ]),
    ),
  );

  Widget _statCard(String emoji, String value, String label, Color bg) => Expanded(
    child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54)),
      ])),
  );

  void _startWeeklyTest() async {
    final weekly = await ApiService.getWeeklyTest();
    if (weekly.isEmpty || weekly['questions'] == null) return;
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => TestScreen(
      questions: (weekly['questions'] as List).map((j) => Map<String, dynamic>.from(j)).toList(),
      title: weekly['title'] ?? 'Weekly Test',
      subject: 'Weekly', chapter: 'Mixed', difficulty: 'medium',
    )));
  }
}
