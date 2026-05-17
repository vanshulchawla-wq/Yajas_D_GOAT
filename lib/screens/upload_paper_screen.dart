import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/api_service.dart';
import 'test_screen.dart';

class UploadPaperScreen extends StatefulWidget {
  const UploadPaperScreen({super.key});
  @override
  State<UploadPaperScreen> createState() => _UploadPaperScreenState();
}

class _UploadPaperScreenState extends State<UploadPaperScreen> {
  final _subjectCtrl = TextEditingController(text: 'Mathematics');
  final _titleCtrl = TextEditingController();
  String _extractedText = '';
  List<Map<String, dynamic>> _parsedQuestions = [];
  bool _processing = false;
  bool _saved = false;
  final _subjects = ['Mathematics', 'Science', 'Social Studies', 'English', 'French', 'General'];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    setState(() => _processing = true);
    try {
      final inputImage = InputImage.fromFilePath(picked.path);
      final recognizer = TextRecognizer();
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();
      setState(() {
        _extractedText = result.text;
        _parsedQuestions = _parseQuestions(result.text);
        _processing = false;
      });
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OCR failed: $e')));
    }
  }

  List<Map<String, dynamic>> _parseQuestions(String text) {
    // Parse questions from OCR text
    // Looks for patterns like "1. question text" or "Q1." followed by options "a) b) c) d)" or "(A) (B) (C) (D)"
    final questions = <Map<String, dynamic>>[];
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    String currentQ = '';
    List<String> currentOpts = [];

    for (final line in lines) {
      final trimmed = line.trim();
      // Check if it's a question start (number followed by text)
      final qMatch = RegExp(r'^(?:Q?\s*)?(\d+)[\.\)\:]?\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      // Check if it's an option
      final optMatch = RegExp(r'^[\(\[]?\s*[a-dA-D1-4][\)\]\.\:]?\s*(.+)').firstMatch(trimmed);

      if (qMatch != null && currentOpts.isEmpty) {
        // Save previous question if exists
        if (currentQ.isNotEmpty && currentOpts.length >= 2) {
          questions.add({'text': currentQ, 'options': List<String>.from(currentOpts), 'correctIndex': 0, 'difficulty': 'medium'});
        }
        currentQ = qMatch.group(2) ?? trimmed;
        currentOpts = [];
      } else if (optMatch != null && currentQ.isNotEmpty) {
        currentOpts.add(optMatch.group(1) ?? trimmed);
      } else if (currentQ.isNotEmpty && currentOpts.isEmpty) {
        // Continuation of question text
        currentQ += ' $trimmed';
      }
    }
    // Save last question
    if (currentQ.isNotEmpty && currentOpts.length >= 2) {
      questions.add({'text': currentQ, 'options': List<String>.from(currentOpts), 'correctIndex': 0, 'difficulty': 'medium'});
    }

    // If no structured questions found, create one big text block
    if (questions.isEmpty && text.length > 20) {
      questions.add({'text': text.substring(0, text.length.clamp(0, 200)), 'options': ['Option A', 'Option B', 'Option C', 'Option D'], 'correctIndex': 0, 'difficulty': 'medium'});
    }

    return questions;
  }

  Future<void> _save() async {
    if (_parsedQuestions.isEmpty) return;
    final title = _titleCtrl.text.trim().isEmpty ? 'Upload ${DateTime.now().day}/${DateTime.now().month}' : _titleCtrl.text.trim();
    setState(() => _processing = true);
    try {
      await ApiService.saveUploadedPaper(subject: _subjectCtrl.text, title: title, questions: _parsedQuestions);
      setState(() { _saved = true; _processing = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Paper saved! Available in practice tests.'), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  void dispose() { _subjectCtrl.dispose(); _titleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Paper', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Instructions
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('📸', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text('Take a photo or pick an image of a question paper. We\'ll extract questions for practice!', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54))),
          ])),
        const SizedBox(height: 16),
        // Subject & Title
        DropdownButtonFormField<String>(
          value: _subjectCtrl.text,
          decoration: InputDecoration(labelText: 'Subject', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => _subjectCtrl.text = v ?? 'General',
        ),
        const SizedBox(height: 12),
        TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Paper Title (optional)', hintText: 'e.g. Chapter 3 Test', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 16),
        // Pick buttons
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            onPressed: _processing ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt), label: const Text('Camera'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: _processing ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library), label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
        const SizedBox(height: 20),
        if (_processing) const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Processing...')])),
        // Extracted text preview
        if (_extractedText.isNotEmpty) ...[
          Text('Extracted Text', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12), height: 120,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
            child: SingleChildScrollView(child: Text(_extractedText, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54))),
          ),
          const SizedBox(height: 16),
        ],
        // Parsed questions
        if (_parsedQuestions.isNotEmpty) ...[
          Row(children: [
            Text('Parsed Questions (${_parsedQuestions.length})', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TestScreen(
                questions: _parsedQuestions, title: _titleCtrl.text.isEmpty ? 'Uploaded Paper' : _titleCtrl.text,
                subject: _subjectCtrl.text, chapter: _titleCtrl.text.isEmpty ? 'Upload' : _titleCtrl.text, difficulty: 'medium',
              )));
            }, child: const Text('Practice Now →')),
          ]),
          const SizedBox(height: 8),
          ..._parsedQuestions.asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Q${e.key + 1}: ${e.value['text']}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Options: ${(e.value['options'] as List).join(' | ')}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          )),
          const SizedBox(height: 16),
          if (!_saved) ElevatedButton.icon(
            onPressed: _processing ? null : _save,
            icon: const Icon(Icons.save),
            label: Text('Save to Question Bank', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ])),
    );
  }
}
