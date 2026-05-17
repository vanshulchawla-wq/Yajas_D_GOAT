import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await ApiService.getResults();
    if (mounted) setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Text('Test History', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('${_results.length} tests', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
      ])),
      if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
      else if (_results.isEmpty) Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📝', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('No tests taken yet', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
      ])))
      else Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _results.length,
        itemBuilder: (_, i) {
          final r = _results[i];
          final pct = (r['percentage'] ?? 0).toDouble();
          final date = (r['date'] ?? '').toString().split('T').first;
          return GestureDetector(
            onTap: () => _showDetail(r),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: _pctColor(pct).withOpacity(0.1)),
                  child: Center(child: Text('${pct.toInt()}%', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _pctColor(pct))))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${r['subject']} - ${r['chapter']}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  Text('${r['score']}/${r['total']} • ${r['difficulty']} • ${r['time_taken'] ?? 0}s', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
                ])),
                Text(date, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38)),
              ]),
            ),
          );
        },
      ))),
    ]));
  }

  void _showDetail(Map<String, dynamic> r) {
    final answers = (r['answers'] as List?) ?? [];
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, expand: false,
        builder: (_, ctrl) => Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),
          Text('${r['subject']} - ${r['chapter']}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Score: ${r['score']}/${r['total']} (${(r['percentage'] ?? 0).toInt()}%)', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(controller: ctrl, itemCount: answers.length, itemBuilder: (_, i) {
            final a = answers[i];
            final correct = a['is_correct'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: correct ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(correct ? Icons.check_circle : Icons.cancel, size: 14, color: correct ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Expanded(child: Text(a['question_text'] ?? '', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
                ]),
                if (!correct) Text('Correct: ${(a['options'] as List)[a['correct_index']]}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.green)),
              ]),
            );
          })),
        ]))));
  }

  Color _pctColor(double p) => p >= 70 ? Colors.green : p >= 40 ? Colors.orange : Colors.red;
}
