import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/game_scaffold.dart';

class TapTapGame extends StatefulWidget {
  const TapTapGame({super.key});
  @override
  State<TapTapGame> createState() => _TapTapGameState();
}

class _TapTapGameState extends State<TapTapGame> {
  List<Map<String, dynamic>> _targets = [];
  int _score = 0;
  int _missed = 0;
  bool _gameOver = false;
  Timer? _timer, _spawnTimer;
  final _rand = Random();
  final _colors = [const Color(0xFFFF4500), const Color(0xFF00E5FF), const Color(0xFFFFEB3B), const Color(0xFF4CAF50), const Color(0xFFE040FB)];

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _targets = []; _score = 0; _missed = 0; _gameOver = false;
    _timer?.cancel(); _spawnTimer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), _tick);
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 600), _spawn);
    setState(() {});
  }

  void _spawn(Timer t) {
    if (_gameOver) return;
    setState(() {
      _targets.add({
        'x': _rand.nextDouble() * 0.8 + 0.1,
        'y': _rand.nextDouble() * 0.7 + 0.1,
        'size': 50.0,
        'life': 1.0,
        'color': _colors[_rand.nextInt(_colors.length)],
      });
    });
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      for (var target in _targets) target['life'] -= 0.015;
      final expired = _targets.where((t) => t['life'] <= 0).length;
      _missed += expired;
      _targets.removeWhere((t) => t['life'] <= 0);
      if (_missed >= 5) { _gameOver = true; _timer?.cancel(); _spawnTimer?.cancel(); }
    });
  }

  void _tapTarget(int i) {
    HapticFeedback.lightImpact();
    setState(() { _score += (20 * _targets[i]['life']).toInt() + 5; _targets.removeAt(i); });
  }

  @override
  void dispose() { _timer?.cancel(); _spawnTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Tap Tap', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFFE040FB),
      child: Stack(children: [
        // Miss counter
        Positioned(top: 10, left: 10, child: Row(children: List.generate(5, (i) => Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(Icons.close, size: 16, color: i < _missed ? Colors.red : Colors.white12),
        )))),
        ..._targets.asMap().entries.map((e) {
          final t = e.value;
          final sz = t['size'] * t['life'];
          return Positioned(
            left: t['x'] * MediaQuery.of(context).size.width - sz / 2,
            top: t['y'] * (MediaQuery.of(context).size.height - 100) - sz / 2,
            child: GestureDetector(
              onTap: () => _tapTarget(e.key),
              child: Container(
                width: sz, height: sz,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (t['color'] as Color).withOpacity(t['life'] as double),
                  border: Border.all(color: (t['color'] as Color), width: 2),
                  boxShadow: [BoxShadow(color: (t['color'] as Color).withOpacity(0.3), blurRadius: 10)],
                ),
              ),
            ),
          );
        }),
      ]),
    );
  }
}
