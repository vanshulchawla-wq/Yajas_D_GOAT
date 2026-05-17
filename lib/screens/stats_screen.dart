import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final stats = await ApiService.getStats();
    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_stats.isEmpty) return Center(child: Text('Take some tests first!', style: GoogleFonts.poppins(color: Colors.black45)));

    final bySubject = (_stats['by_subject'] as Map<String, dynamic>?) ?? {};
    final byDate = (_stats['by_date'] as List?) ?? [];

    return SafeArea(child: RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Performance', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        // Overall card
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _overStat('${(_stats['avg_score'] ?? 0).toInt()}%', 'Average'),
            _overStat('${_stats['total_tests'] ?? 0}', 'Tests'),
            _overStat('${_stats['streak'] ?? 0}', 'Streak'),
            _overStat('${_stats['mastered'] ?? 0}', 'Mastered'),
          ])),
        const SizedBox(height: 24),
        // By subject
        Text('By Subject', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...bySubject.entries.map((e) {
          final avg = (e.value['avg_percentage'] ?? 0).toDouble();
          return Container(
            margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(e.key, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))),
                Text('${avg.toInt()}%', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _pctColor(avg))),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: avg / 100, color: _pctColor(avg), backgroundColor: _pctColor(avg).withOpacity(0.1), minHeight: 6)),
              const SizedBox(height: 4),
              Text('${e.value['tests']} tests • ${e.value['total_score']}/${e.value['total_possible']} correct', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
            ]),
          );
        }),
        // Date trend
        if (byDate.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Last 14 Days', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(height: 120, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ...byDate.reversed.map((d) {
              final avg = (d['avg'] ?? 0).toDouble();
              return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${avg.toInt()}', style: GoogleFonts.poppins(fontSize: 8, color: Colors.black45)),
                  const SizedBox(height: 2),
                  Container(height: avg, decoration: BoxDecoration(color: _pctColor(avg), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 4),
                  Text((d['date'] ?? '').toString().substring(8), style: GoogleFonts.poppins(fontSize: 8, color: Colors.black38)),
                ]),
              ));
            }),
          ])),
        ],
      ]),
    )));
  }

  Widget _overStat(String val, String label) => Column(children: [
    Text(val, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
    Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60)),
  ]);

  Color _pctColor(double p) => p >= 70 ? Colors.green : p >= 40 ? Colors.orange : Colors.red;
}
