import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final bm = await ApiService.getBookmarks();
    if (mounted) setState(() { _bookmarks = bm; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks (${_bookmarks.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : _bookmarks.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No bookmarks!', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Wrong answers appear here for review', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
          ]))
        : RefreshIndicator(onRefresh: _load, child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _bookmarks.length,
            itemBuilder: (_, i) {
              final b = _bookmarks[i];
              final options = List<String>.from(b['options'] ?? []);
              final correctIdx = b['correct_index'] ?? 0;
              return Dismissible(
                key: Key(b['question_id'] ?? '$i'),
                direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.check, color: Colors.white)),
                onDismissed: (_) async {
                  await ApiService.removeBookmark(b['question_id'] ?? '');
                  setState(() => _bookmarks.removeAt(i));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('${b['subject']}', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF1565C0)))),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${b['chapter']}', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black45))),
                    ]),
                    const SizedBox(height: 8),
                    Text(b['question_text'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(correctIdx < options.length ? options[correctIdx] : '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600))),
                      ])),
                    const SizedBox(height: 6),
                    Text('Swipe right to mark as learned →', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black26)),
                  ]),
                ),
              );
            },
          )),
    );
  }
}
