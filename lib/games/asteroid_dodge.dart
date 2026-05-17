import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class AsteroidDodgeGame extends StatefulWidget {
  const AsteroidDodgeGame({super.key});
  @override
  State<AsteroidDodgeGame> createState() => _AsteroidDodgeGameState();
}

class _AsteroidDodgeGameState extends State<AsteroidDodgeGame> {
  double _shipX = 0.5, _shipY = 0.8;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _asteroids = [];
  List<Map<String, double>> _stars = [];
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _shipX = 0.5; _shipY = 0.8; _score = 0; _gameOver = false; _asteroids = [];
    _stars = List.generate(20, (_) => {'x': _rand.nextDouble(), 'y': _rand.nextDouble(), 's': _rand.nextDouble() * 2 + 0.5});
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 25), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _score++;
      final speed = 0.008 + _score * 0.00003;
      if (_rand.nextInt(20) == 0) {
        _asteroids.add({'x': _rand.nextDouble() * 0.9 + 0.05, 'y': -0.05, 'size': _rand.nextDouble() * 0.03 + 0.02, 'rot': _rand.nextDouble() * 6.28});
      }
      _asteroids = _asteroids.map((a) => {'x': a['x']!, 'y': a['y']! + speed, 'size': a['size']!, 'rot': a['rot']! + 0.05}).where((a) => a['y']! < 1.1).toList();
      for (var a in _asteroids) {
        if ((a['x']! - _shipX).abs() < a['size']! + 0.03 && (a['y']! - _shipY).abs() < a['size']! + 0.03) {
          _gameOver = true; _timer?.cancel();
        }
      }
      for (var s in _stars) s['y'] = (s['y']! + 0.002) % 1.0;
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Asteroid Dodge', score: _score ~/ 4, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFFFF5722),
      child: GestureDetector(
        onPanUpdate: (d) {
          final s = MediaQuery.of(context).size;
          setState(() { _shipX = (d.localPosition.dx / s.width).clamp(0.05, 0.95); _shipY = (d.localPosition.dy / (s.height - 100)).clamp(0.3, 0.95); });
        },
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _AsteroidPainter(shipX: _shipX, shipY: _shipY, asteroids: _asteroids, stars: _stars),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _AsteroidPainter extends CustomPainter {
  final double shipX, shipY;
  final List<Map<String, double>> asteroids, stars;
  _AsteroidPainter({required this.shipX, required this.shipY, required this.asteroids, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    for (var s in stars) canvas.drawCircle(Offset(s['x']! * size.width, s['y']! * size.height), s['s']!, Paint()..color = Colors.white24);
    // Ship
    final sx = shipX * size.width, sy = shipY * size.height;
    canvas.drawPath(Path()..moveTo(sx, sy - 18)..lineTo(sx - 12, sy + 12)..lineTo(sx, sy + 6)..lineTo(sx + 12, sy + 12)..close(), Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(sx, sy + 14), 4, Paint()..color = Colors.orange);
    // Asteroids
    for (var a in asteroids) {
      final ax = a['x']! * size.width, ay = a['y']! * size.height, as2 = a['size']! * size.width;
      canvas.save(); canvas.translate(ax, ay); canvas.rotate(a['rot']!);
      canvas.drawPath(_asteroidPath(as2), Paint()..color = const Color(0xFF795548));
      canvas.restore();
    }
  }

  Path _asteroidPath(double r) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 * 2 / 8;
      final rr = r * (0.7 + (i % 3) * 0.15);
      final x = cos(angle) * rr, y = sin(angle) * rr;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
