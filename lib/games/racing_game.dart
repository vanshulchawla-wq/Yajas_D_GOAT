import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class RacingGame extends StatefulWidget {
  const RacingGame({super.key});
  @override
  State<RacingGame> createState() => _RacingGameState();
}

class _RacingGameState extends State<RacingGame> {
  double _carX = 0.5;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _enemies = [];
  List<double> _roadLines = [0.0, 0.25, 0.5, 0.75];
  double _speed = 0.01;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _carX = 0.5; _score = 0; _gameOver = false; _enemies = []; _speed = 0.01;
    _roadLines = [0.0, 0.25, 0.5, 0.75];
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _score++;
      _speed = min(0.025, 0.01 + _score * 0.00005);

      // Road lines
      for (int i = 0; i < _roadLines.length; i++) {
        _roadLines[i] += _speed * 2;
        if (_roadLines[i] > 1) _roadLines[i] -= 1;
      }

      // Spawn enemies
      if (_rand.nextInt(40) == 0) {
        final lanes = [0.25, 0.4, 0.55, 0.7];
        _enemies.add({'x': lanes[_rand.nextInt(4)], 'y': -0.1});
      }

      // Move enemies
      _enemies = _enemies.map((e) => {'x': e['x']!, 'y': e['y']! + _speed}).where((e) => e['y']! < 1.2).toList();

      // Collision
      for (var e in _enemies) {
        if ((e['x']! - _carX).abs() < 0.08 && (e['y']! - 0.8).abs() < 0.05) {
          _gameOver = true; _timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Racing', score: _score ~/ 5, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF2196F3),
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _carX = (d.localPosition.dx / MediaQuery.of(context).size.width).clamp(0.15, 0.85)),
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _RacingPainter(carX: _carX, enemies: _enemies, roadLines: _roadLines),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _RacingPainter extends CustomPainter {
  final double carX;
  final List<Map<String, double>> enemies;
  final List<double> roadLines;
  _RacingPainter({required this.carX, required this.enemies, required this.roadLines});

  @override
  void paint(Canvas canvas, Size size) {
    // Road
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, 0, size.width * 0.7, size.height), Paint()..color = const Color(0xFF37474F));
    // Road edges
    canvas.drawRect(Rect.fromLTWH(size.width * 0.14, 0, 4, size.height), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.85, 0, 4, size.height), Paint()..color = Colors.white);
    // Road lines
    for (final ly in roadLines) {
      for (int i = 0; i < 8; i++) {
        final y = (ly + i * 0.125) % 1.0;
        canvas.drawRect(Rect.fromLTWH(size.width * 0.495, y * size.height, 4, 30), Paint()..color = Colors.yellow.withOpacity(0.6));
      }
    }
    // Player car
    _drawCar(canvas, size, carX, 0.8, const Color(0xFF2196F3));
    // Enemy cars
    for (final e in enemies) _drawCar(canvas, size, e['x']!, e['y']!, Colors.red);
  }

  void _drawCar(Canvas canvas, Size size, double x, double y, Color color) {
    final cx = x * size.width;
    final cy = y * size.height;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 50), const Radius.circular(6)), Paint()..color = color);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 5), width: 22, height: 20), const Radius.circular(4)), Paint()..color = color.withOpacity(0.7));
    // Wheels
    canvas.drawRect(Rect.fromLTWH(cx - 17, cy - 15, 5, 12), Paint()..color = Colors.black87);
    canvas.drawRect(Rect.fromLTWH(cx + 12, cy - 15, 5, 12), Paint()..color = Colors.black87);
    canvas.drawRect(Rect.fromLTWH(cx - 17, cy + 8, 5, 12), Paint()..color = Colors.black87);
    canvas.drawRect(Rect.fromLTWH(cx + 12, cy + 8, 5, 12), Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
