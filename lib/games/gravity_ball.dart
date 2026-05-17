import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class GravityBallGame extends StatefulWidget {
  const GravityBallGame({super.key});
  @override
  State<GravityBallGame> createState() => _GravityBallGameState();
}

class _GravityBallGameState extends State<GravityBallGame> {
  double _ballX = 0.5, _ballY = 0.5;
  double _vx = 0, _vy = 0;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _walls = [];
  Map<String, double> _goal = {'x': 0.8, 'y': 0.2};
  int _level = 1;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _generateLevel(); }

  void _generateLevel() {
    _ballX = 0.1; _ballY = 0.9; _vx = 0; _vy = 0; _gameOver = false;
    _walls = [];
    for (int i = 0; i < 3 + _level; i++) {
      _walls.add({'x': _rand.nextDouble() * 0.7 + 0.1, 'y': _rand.nextDouble() * 0.6 + 0.2, 'w': _rand.nextDouble() * 0.2 + 0.1, 'h': 0.02});
    }
    _goal = {'x': _rand.nextDouble() * 0.5 + 0.4, 'y': _rand.nextDouble() * 0.3 + 0.1};
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _vy += 0.0005; // gravity
      _ballX += _vx; _ballY += _vy;
      _vx *= 0.98; _vy *= 0.98;

      // Walls
      if (_ballX < 0.02 || _ballX > 0.98) { _vx = -_vx * 0.5; _ballX = _ballX.clamp(0.02, 0.98); }
      if (_ballY < 0.02 || _ballY > 0.98) { _vy = -_vy * 0.5; _ballY = _ballY.clamp(0.02, 0.98); }

      // Obstacle collision
      for (var w in _walls) {
        if (_ballX >= w['x']! && _ballX <= w['x']! + w['w']! && (_ballY - w['y']!).abs() < 0.025) {
          _vy = -_vy * 0.7;
          _ballY = w['y']! + (_vy > 0 ? -0.025 : 0.025);
        }
      }

      // Goal
      if ((_ballX - _goal['x']!).abs() < 0.04 && (_ballY - _goal['y']!).abs() < 0.04) {
        _score += 20 + _level * 5;
        _level++;
        _generateLevel();
      }
    });
  }

  void _applyForce(Offset delta) {
    _vx += delta.dx * 0.0001;
    _vy += delta.dy * 0.0001;
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Gravity Ball', score: _score, isGameOver: _gameOver,
      onRestart: () { _score = 0; _level = 1; _generateLevel(); },
      accentColor: const Color(0xFF304FFE),
      child: GestureDetector(
        onPanUpdate: (d) => _applyForce(d.delta),
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _GravityPainter(ballX: _ballX, ballY: _ballY, walls: _walls, goal: _goal, level: _level),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _GravityPainter extends CustomPainter {
  final double ballX, ballY;
  final List<Map<String, double>> walls;
  final Map<String, double> goal;
  final int level;
  _GravityPainter({required this.ballX, required this.ballY, required this.walls, required this.goal, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    // Border
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0D0D1A)..style = PaintingStyle.fill);
    canvas.drawRect(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), Paint()..color = const Color(0xFF304FFE).withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Walls
    for (var w in walls) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w['x']! * size.width, w['y']! * size.height, w['w']! * size.width, w['h']! * size.height + 6), const Radius.circular(3)),
        Paint()..color = const Color(0xFF455A64));
    }

    // Goal
    canvas.drawCircle(Offset(goal['x']! * size.width, goal['y']! * size.height), 16, Paint()..color = Colors.greenAccent.withOpacity(0.3));
    canvas.drawCircle(Offset(goal['x']! * size.width, goal['y']! * size.height), 10, Paint()..color = Colors.greenAccent);

    // Ball
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 12, Paint()..color = const Color(0xFF304FFE));
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 16, Paint()..color = const Color(0xFF304FFE).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Level
    final tp = TextPainter(text: TextSpan(text: 'LVL $level', style: TextStyle(color: Colors.white24, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(size.width - 50, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
