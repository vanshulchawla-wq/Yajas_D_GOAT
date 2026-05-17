import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class BubbleShooterGame extends StatefulWidget {
  const BubbleShooterGame({super.key});
  @override
  State<BubbleShooterGame> createState() => _BubbleShooterGameState();
}

class _BubbleShooterGameState extends State<BubbleShooterGame> {
  List<Map<String, dynamic>> _bubbles = [];
  int _score = 0;
  int _timeLeft = 30;
  bool _gameOver = false;
  Timer? _timer, _spawnTimer;
  final _rand = Random();
  final _colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _bubbles = []; _score = 0; _timeLeft = 30; _gameOver = false;
    _timer?.cancel(); _spawnTimer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() { _timeLeft--; if (_timeLeft <= 0) { _gameOver = true; t.cancel(); _spawnTimer?.cancel(); } });
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (_gameOver) return;
      setState(() {
        _bubbles.add({'x': _rand.nextDouble() * 0.8 + 0.1, 'y': 1.0, 'color': _colors[_rand.nextInt(_colors.length)], 'size': _rand.nextDouble() * 20 + 25, 'speed': _rand.nextDouble() * 0.003 + 0.002});
      });
    });
    setState(() {});
  }

  void _pop(int i) {
    setState(() { _score += (50 - _bubbles[i]['size']).toInt().clamp(5, 20); _bubbles.removeAt(i); });
  }

  void _tick() {
    _bubbles = _bubbles.map((b) { b['y'] -= b['speed']; return b; }).where((b) => b['y'] > -0.1).toList();
  }

  @override
  void dispose() { _timer?.cancel(); _spawnTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    _tick();
    return GameScaffold(
      title: 'Bubble Pop', score: _score, isGameOver: _gameOver,
      onRestart: _startGame, accentColor: const Color(0xFF00BCD4),
      child: Stack(children: [
        ..._bubbles.asMap().entries.map((e) {
          final b = e.value;
          return Positioned(
            left: b['x'] * MediaQuery.of(context).size.width - b['size'] / 2,
            top: b['y'] * (MediaQuery.of(context).size.height - 100) - b['size'] / 2,
            child: GestureDetector(
              onTap: () => _pop(e.key),
              child: Container(
                width: b['size'], height: b['size'],
                decoration: BoxDecoration(shape: BoxShape.circle, color: (b['color'] as Color).withOpacity(0.7),
                  border: Border.all(color: (b['color'] as Color), width: 2),
                  boxShadow: [BoxShadow(color: (b['color'] as Color).withOpacity(0.3), blurRadius: 8)]),
              ),
            ),
          );
        }),
        Positioned(top: 10, right: 10, child: Text('⏱️ $_timeLeft', style: const TextStyle(color: Colors.white70, fontSize: 16))),
      ]),
    );
  }
}
