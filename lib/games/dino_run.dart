import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class DinoRunGame extends StatefulWidget {
  const DinoRunGame({super.key});
  @override
  State<DinoRunGame> createState() => _DinoRunGameState();
}

class _DinoRunGameState extends State<DinoRunGame> {
  double _dinoY = 0;
  double _velocity = 0;
  bool _jumping = false;
  int _score = 0;
  bool _gameOver = false;
  List<double> _obstacles = [1.0, 1.8, 2.5];
  List<bool> _isBird = [false, false, true];
  double _speed = 0.012;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _dinoY = 0; _velocity = 0; _jumping = false; _score = 0; _gameOver = false;
    _obstacles = [1.0, 1.8, 2.5]; _isBird = [false, false, true]; _speed = 0.012;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      // Gravity
      if (_jumping) {
        _velocity += 0.003;
        _dinoY += _velocity;
        if (_dinoY >= 0) { _dinoY = 0; _jumping = false; _velocity = 0; }
      }

      // Move obstacles
      for (int i = 0; i < _obstacles.length; i++) {
        _obstacles[i] -= _speed;
        if (_obstacles[i] < -0.1) {
          _obstacles[i] = _obstacles.reduce(max) + 0.5 + _rand.nextDouble() * 0.4;
          _isBird[i] = _rand.nextBool();
          _score += 10;
          _speed = min(0.025, _speed + 0.0003);
        }
        // Collision
        if (_obstacles[i] > 0.08 && _obstacles[i] < 0.18) {
          if (_isBird[i]) {
            if (_dinoY > -0.15 && _dinoY < -0.05) { _gameOver = true; _timer?.cancel(); }
          } else {
            if (_dinoY > -0.12) { _gameOver = true; _timer?.cancel(); }
          }
        }
      }
    });
  }

  void _jump() {
    if (!_jumping && !_gameOver) { _jumping = true; _velocity = -0.04; }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Dino Run', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF795548),
      child: GestureDetector(
        onTap: _jump,
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _DinoPainter(dinoY: _dinoY, obstacles: _obstacles, isBird: _isBird, score: _score),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _DinoPainter extends CustomPainter {
  final double dinoY;
  final List<double> obstacles;
  final List<bool> isBird;
  final int score;
  _DinoPainter({required this.dinoY, required this.obstacles, required this.isBird, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height * 0.75;

    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, ground), Paint()..color = const Color(0xFF1A1A2E));
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, ground, size.width, size.height - ground), Paint()..color = const Color(0xFF2D1B0E));
    canvas.drawLine(Offset(0, ground), Offset(size.width, ground), Paint()..color = Colors.white12..strokeWidth = 2);

    // Dino
    final dx = size.width * 0.12;
    final dy = ground + dinoY * size.height * 2 - 40;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(dx, dy, 25, 40), const Radius.circular(4)), Paint()..color = const Color(0xFF4CAF50));
    canvas.drawCircle(Offset(dx + 20, dy + 5), 8, Paint()..color = const Color(0xFF388E3C));
    canvas.drawCircle(Offset(dx + 23, dy + 3), 3, Paint()..color = Colors.white);

    // Obstacles
    for (int i = 0; i < obstacles.length; i++) {
      final ox = obstacles[i] * size.width;
      if (isBird[i]) {
        final oy = ground - 60;
        canvas.drawPath(Path()..moveTo(ox, oy)..lineTo(ox - 15, oy + 8)..lineTo(ox + 15, oy + 8)..close(), Paint()..color = Colors.redAccent);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox, ground - 35, 18, 35), const Radius.circular(2)), Paint()..color = const Color(0xFF795548));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox - 5, ground - 40, 28, 10), const Radius.circular(4)), Paint()..color = const Color(0xFF4E342E));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
