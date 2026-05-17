import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class MathBlitzGame extends StatefulWidget {
  const MathBlitzGame({super.key});
  @override
  State<MathBlitzGame> createState() => _MathBlitzGameState();
}

class _MathBlitzGameState extends State<MathBlitzGame> {
  int _a = 0, _b = 0, _answer = 0;
  String _op = '+';
  List<int> _options = [];
  int _score = 0;
  int _streak = 0;
  double _timeLeft = 1.0;
  bool _gameOver = false;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _nextProblem(); }

  void _nextProblem() {
    final ops = ['+', '-', '×'];
    _op = ops[_rand.nextInt(ops.length)];
    _a = _rand.nextInt(20) + 1;
    _b = _rand.nextInt(15) + 1;
    if (_op == '-' && _b > _a) { final t = _a; _a = _b; _b = t; }
    _answer = _op == '+' ? _a + _b : _op == '-' ? _a - _b : _a * _b;
    _options = [_answer];
    while (_options.length < 4) {
      final wrong = _answer + _rand.nextInt(10) - 5;
      if (wrong != _answer && !_options.contains(wrong)) _options.add(wrong);
    }
    _options.shuffle(_rand);
    _timeLeft = 1.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        _timeLeft -= 0.02;
        if (_timeLeft <= 0) { _gameOver = true; t.cancel(); }
      });
    });
    setState(() {});
  }

  void _pick(int val) {
    if (_gameOver) return;
    if (val == _answer) {
      _streak++;
      _score += 10 + (_streak * 2);
      _nextProblem();
    } else {
      _streak = 0;
      _score = max(0, _score - 5);
      setState(() {});
    }
  }

  void _restart() { _score = 0; _streak = 0; _gameOver = false; _nextProblem(); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Math Blitz', score: _score, isGameOver: _gameOver,
      onRestart: _restart, accentColor: const Color(0xFF1DE9B6),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_streak > 2) Text('🔥 $_streak streak!', style: GoogleFonts.inter(fontSize: 14, color: Colors.orange)),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: _timeLeft, color: _timeLeft > 0.3 ? const Color(0xFF1DE9B6) : Colors.red, backgroundColor: Colors.white12),
        const SizedBox(height: 40),
        Text('$_a $_op $_b = ?', style: GoogleFonts.orbitron(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 40),
        Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _options.map((o) => SizedBox(
          width: 100, height: 60,
          child: ElevatedButton(
            onPressed: () => _pick(o),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), side: const BorderSide(color: Color(0xFF1DE9B6)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('$o', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
          ),
        )).toList()),
      ]),
    );
  }
}
