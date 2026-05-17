import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({super.key});
  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final _words = ['FLUTTER', 'GAMING', 'ROCKET', 'PLANET', 'DRAGON', 'KNIGHT', 'CASTLE', 'WIZARD', 'PIRATE', 'JUNGLE', 'GALAXY', 'SHADOW', 'THUNDER', 'CRYSTAL', 'PHOENIX'];
  String _currentWord = '';
  String _scrambled = '';
  String _guess = '';
  int _score = 0;
  int _lives = 3;
  bool _gameOver = false;
  final _rand = Random();

  @override
  void initState() { super.initState(); _nextWord(); }

  void _nextWord() {
    _currentWord = _words[_rand.nextInt(_words.length)];
    final chars = _currentWord.split('')..shuffle(_rand);
    _scrambled = chars.join();
    if (_scrambled == _currentWord) _scrambled = chars.reversed.join();
    _guess = '';
    setState(() {});
  }

  void _addLetter(String l) { setState(() => _guess += l); }
  void _removeLetter() { if (_guess.isNotEmpty) setState(() => _guess = _guess.substring(0, _guess.length - 1)); }

  void _submit() {
    if (_guess.toUpperCase() == _currentWord) {
      _score += 20 + (_currentWord.length * 2);
      _nextWord();
    } else {
      _lives--;
      if (_lives <= 0) setState(() => _gameOver = true);
      else setState(() => _guess = '');
    }
  }

  void _skip() { _lives--; if (_lives <= 0) setState(() => _gameOver = true); else _nextWord(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Word Scramble', score: _score, isGameOver: _gameOver,
      onRestart: () { _score = 0; _lives = 3; _gameOver = false; _nextWord(); },
      accentColor: const Color(0xFF673AB7),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_lives, (_) => const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.favorite, color: Colors.red, size: 20)))),
        const SizedBox(height: 30),
        Text('Unscramble:', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(spacing: 6, children: _scrambled.split('').map((c) => Container(
          width: 38, height: 44, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.3), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF673AB7))),
          child: Text(c, style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        )).toList()),
        const SizedBox(height: 30),
        // Guess display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
          child: Text(_guess.isEmpty ? '...' : _guess, style: GoogleFonts.orbitron(fontSize: 22, color: Colors.white, letterSpacing: 4)),
        ),
        const SizedBox(height: 20),
        // Keyboard
        Wrap(spacing: 4, runSpacing: 4, alignment: WrapAlignment.center, children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((c) => SizedBox(
          width: 34, height: 38,
          child: ElevatedButton(
            onPressed: () => _addLetter(c),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            child: Text(c, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ),
        )).toList()),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(onPressed: _removeLetter, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.3)), child: const Icon(Icons.backspace, size: 18)),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7)), child: Text('CHECK', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _skip, style: ElevatedButton.styleFrom(backgroundColor: Colors.white12), child: Text('SKIP', style: GoogleFonts.inter(color: Colors.white54))),
        ]),
      ]),
    );
  }
}
