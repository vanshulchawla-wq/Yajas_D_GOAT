import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class ReactionTimeGame extends StatefulWidget {
  const ReactionTimeGame({super.key});
  @override
  State<ReactionTimeGame> createState() => _ReactionTimeGameState();
}

class _ReactionTimeGameState extends State<ReactionTimeGame> {
  int _score = 0;
  int _round = 0;
  int _reactionMs = 0;
  List<int> _times = [];
  bool _waiting = false;
  bool _ready = false;
  bool _tooEarly = false;
  bool _gameOver = false;
  DateTime? _startTime;
  Timer? _timer;

  void _startRound() {
    setState(() { _waiting = true; _ready = false; _tooEarly = false; });
    final delay = Random().nextInt(3000) + 1500;
    _timer = Timer(Duration(milliseconds: delay), () {
      if (mounted) setState(() { _waiting = false; _ready = true; _startTime = DateTime.now(); });
    });
  }

  void _tap() {
    if (_gameOver) return;
    if (_waiting) {
      _timer?.cancel();
      setState(() { _tooEarly = true; _waiting = false; });
      Future.delayed(const Duration(seconds: 1), () { if (mounted) _startRound(); });
      return;
    }
    if (_ready) {
      final ms = DateTime.now().difference(_startTime!).inMilliseconds;
      setState(() {
        _reactionMs = ms;
        _times.add(ms);
        _round++;
        _ready = false;
        _score += max(0, 500 - ms);
      });
      if (_round >= 5) {
        setState(() => _gameOver = true);
      } else {
        Future.delayed(const Duration(seconds: 1), () { if (mounted) _startRound(); });
      }
    }
  }

  void _restart() {
    _score = 0; _round = 0; _times = []; _gameOver = false; _reactionMs = 0;
    _startRound();
  }

  @override
  void initState() { super.initState(); _startRound(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Reaction Time', score: _score, isGameOver: _gameOver,
      onRestart: _restart, accentColor: const Color(0xFFFFC107),
      child: GestureDetector(
        onTap: _tap,
        child: Container(
          color: _ready ? Colors.green : _tooEarly ? Colors.red.withOpacity(0.3) : _waiting ? const Color(0xFFFFC107).withOpacity(0.1) : Colors.transparent,
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Round ${_round + 1}/5', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 20),
            if (_waiting) ...[
              const Icon(Icons.hourglass_top, color: Color(0xFFFFC107), size: 60),
              const SizedBox(height: 16),
              Text('Wait for GREEN...', style: GoogleFonts.orbitron(fontSize: 18, color: const Color(0xFFFFC107))),
            ] else if (_ready) ...[
              const Icon(Icons.touch_app, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text('TAP NOW!', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green)),
            ] else if (_tooEarly) ...[
              Text('Too early! ❌', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.red)),
            ] else if (_reactionMs > 0) ...[
              Text('${_reactionMs}ms', style: GoogleFonts.orbitron(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(_reactionMs < 200 ? '⚡ Lightning!' : _reactionMs < 300 ? '🔥 Fast!' : '👍 Good', style: GoogleFonts.inter(fontSize: 16, color: Colors.white54)),
            ] else ...[
              Text('Tap to begin', style: GoogleFonts.inter(fontSize: 16, color: Colors.white38)),
            ],
            if (_times.isNotEmpty) ...[
              const SizedBox(height: 30),
              Text('Avg: ${(_times.reduce((a, b) => a + b) / _times.length).round()}ms', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
            ],
          ])),
        ),
      ),
    );
  }
}
