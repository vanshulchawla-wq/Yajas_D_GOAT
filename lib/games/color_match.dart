import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});
  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  final _colors = {'Red': Colors.red, 'Blue': Colors.blue, 'Green': Colors.green, 'Yellow': Colors.yellow, 'Purple': Colors.purple, 'Orange': Colors.orange};
  String _word = 'Red';
  Color _displayColor = Colors.blue;
  int _score = 0;
  int _lives = 3;
  bool _gameOver = false;
  double _timeLeft = 1.0;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _nextRound(); }

  void _nextRound() {
    final keys = _colors.keys.toList();
    _word = keys[_rand.nextInt(keys.length)];
    _displayColor = _colors.values.toList()[_rand.nextInt(_colors.length)];
    _timeLeft = 1.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        _timeLeft -= 0.025;
        if (_timeLeft <= 0) { _lives--; if (_lives <= 0) { _gameOver = true; t.cancel(); } else _nextRound(); }
      });
    });
  }

  void _answer(bool matchesColor) {
    final actual = _displayColor == _colors[_word];
    if (matchesColor == actual) { _score += 10; } else { _lives--; }
    if (_lives <= 0) { setState(() => _gameOver = true); _timer?.cancel(); return; }
    setState(_nextRound);
  }

  void _restart() { _score = 0; _lives = 3; _gameOver = false; _nextRound(); setState(() {}); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Color Match', score: _score, isGameOver: _gameOver,
      onRestart: _restart, accentColor: const Color(0xFFFF9800),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_lives, (_) => const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.favorite, color: Colors.red, size: 24)))),
        const SizedBox(height: 20),
        LinearProgressIndicator(value: _timeLeft, color: _timeLeft > 0.3 ? const Color(0xFFFF9800) : Colors.red, backgroundColor: Colors.white12),
        const SizedBox(height: 40),
        Text('Does the COLOR match\nthe WORD?', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 30),
        Text(_word, style: GoogleFonts.orbitron(fontSize: 48, fontWeight: FontWeight.w900, color: _displayColor)),
        const SizedBox(height: 50),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(onPressed: () => _answer(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('YES', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700))),
          const SizedBox(width: 24),
          ElevatedButton(onPressed: () => _answer(false), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('NO', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700))),
        ]),
      ]),
    );
  }
}
