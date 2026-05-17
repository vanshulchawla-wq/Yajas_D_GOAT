import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class WhackAMoleGame extends StatefulWidget {
  const WhackAMoleGame({super.key});
  @override
  State<WhackAMoleGame> createState() => _WhackAMoleGameState();
}

class _WhackAMoleGameState extends State<WhackAMoleGame> {
  List<bool> _moles = List.filled(9, false);
  List<bool> _hit = List.filled(9, false);
  int _score = 0;
  int _timeLeft = 30;
  bool _gameOver = false;
  Timer? _moleTimer, _clockTimer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _moles = List.filled(9, false); _hit = List.filled(9, false);
    _score = 0; _timeLeft = 30; _gameOver = false;
    _moleTimer?.cancel(); _clockTimer?.cancel();
    _moleTimer = Timer.periodic(Duration(milliseconds: 800 - min(400, _score * 5)), _spawnMole);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() { _timeLeft--; if (_timeLeft <= 0) { _gameOver = true; t.cancel(); _moleTimer?.cancel(); } });
    });
    setState(() {});
  }

  void _spawnMole(Timer t) {
    if (_gameOver) return;
    setState(() {
      _moles = List.filled(9, false);
      _hit = List.filled(9, false);
      final count = min(3, 1 + _score ~/ 50);
      for (int i = 0; i < count; i++) _moles[_rand.nextInt(9)] = true;
    });
  }

  void _whack(int i) {
    if (!_moles[i] || _hit[i] || _gameOver) return;
    HapticFeedback.mediumImpact();
    setState(() { _hit[i] = true; _moles[i] = false; _score += 10; });
  }

  @override
  void dispose() { _moleTimer?.cancel(); _clockTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Whack-a-Mole', score: _score, isGameOver: _gameOver,
      onRestart: _startGame, accentColor: const Color(0xFF8D6E63),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.timer, color: Colors.white54, size: 18),
          const SizedBox(width: 4),
          Text('${_timeLeft}s', style: GoogleFonts.orbitron(fontSize: 18, color: _timeLeft <= 5 ? Colors.red : Colors.white)),
        ])),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16),
          itemCount: 9,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _whack(i),
            child: Container(
              decoration: BoxDecoration(
                color: _hit[i] ? Colors.orange.withOpacity(0.3) : const Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF5D4037), width: 3),
              ),
              child: Center(child: AnimatedScale(
                scale: _moles[i] ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(_hit[i] ? '💥' : '🐹', style: const TextStyle(fontSize: 36)),
              )),
            ),
          ),
        )),
      ]),
    );
  }
}
