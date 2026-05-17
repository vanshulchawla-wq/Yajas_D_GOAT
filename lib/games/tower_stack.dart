import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class TowerStackGame extends StatefulWidget {
  const TowerStackGame({super.key});
  @override
  State<TowerStackGame> createState() => _TowerStackGameState();
}

class _TowerStackGameState extends State<TowerStackGame> {
  double _blockX = 0;
  double _blockWidth = 0.4;
  double _speed = 0.015;
  int _dir = 1;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _stack = [];
  Timer? _timer;

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _blockX = 0; _blockWidth = 0.4; _speed = 0.015; _dir = 1; _score = 0; _gameOver = false;
    _stack = [{'x': 0.3, 'w': 0.4}];
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _blockX += _speed * _dir;
      if (_blockX + _blockWidth > 1 || _blockX < 0) _dir = -_dir;
    });
  }

  void _drop() {
    if (_gameOver) return;
    final prev = _stack.last;
    final overlap = _getOverlap(_blockX, _blockWidth, prev['x']!, prev['w']!);
    if (overlap <= 0) {
      setState(() { _gameOver = true; _timer?.cancel(); });
      return;
    }
    final newX = _blockX < prev['x']! ? prev['x']! : _blockX;
    setState(() {
      _stack.add({'x': newX, 'w': overlap});
      _blockWidth = overlap;
      _blockX = 0;
      _score += 10;
      _speed += 0.001;
      if ((overlap - prev['w']!).abs() < 0.01) _score += 5; // Perfect bonus
    });
  }

  double _getOverlap(double x1, double w1, double x2, double w2) {
    final left = x1 > x2 ? x1 : x2;
    final right = (x1 + w1) < (x2 + w2) ? (x1 + w1) : (x2 + w2);
    return right - left;
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Tower Stack', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF455A64),
      child: GestureDetector(
        onTap: _drop,
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _TowerPainter(blockX: _blockX, blockWidth: _blockWidth, stack: _stack),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _TowerPainter extends CustomPainter {
  final double blockX, blockWidth;
  final List<Map<String, double>> stack;
  _TowerPainter({required this.blockX, required this.blockWidth, required this.stack});

  @override
  void paint(Canvas canvas, Size size) {
    final blockH = 20.0;
    final colors = [const Color(0xFFFF4500), const Color(0xFF00E5FF), const Color(0xFFFFEB3B), const Color(0xFF4CAF50), const Color(0xFF9C27B0), const Color(0xFFFF9800)];

    // Stack
    final visibleStart = stack.length > 15 ? stack.length - 15 : 0;
    for (int i = visibleStart; i < stack.length; i++) {
      final s = stack[i];
      final y = size.height - (i - visibleStart + 1) * blockH;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s['x']! * size.width, y, s['w']! * size.width, blockH - 2), const Radius.circular(3)),
        Paint()..color = colors[i % colors.length]);
    }

    // Moving block
    final movY = size.height - (stack.length - visibleStart + 1) * blockH;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(blockX * size.width, movY, blockWidth * size.width, blockH - 2), const Radius.circular(3)),
      Paint()..color = colors[stack.length % colors.length].withOpacity(0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
