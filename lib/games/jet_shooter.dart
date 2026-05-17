import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class JetShooterGame extends StatefulWidget {
  const JetShooterGame({super.key});
  @override
  State<JetShooterGame> createState() => _JetShooterGameState();
}

class _JetShooterGameState extends State<JetShooterGame> {
  double _jetX = 0.5;
  double _jetY = 0.8;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _bullets = [];
  List<Map<String, double>> _enemies = [];
  List<Map<String, double>> _explosions = [];
  Timer? _timer;
  final _rand = Random();
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _gameOver = false;
    _bullets = [];
    _enemies = [];
    _explosions = [];
    _jetX = 0.5;
    _level = 1;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), _tick);
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      // Move bullets up
      _bullets = _bullets.map((b) => {'x': b['x']!, 'y': b['y']! - 0.02}).where((b) => b['y']! > 0).toList();

      // Move enemies down
      _enemies = _enemies.map((e) => {'x': e['x']!, 'y': e['y']! + 0.005 + (_level * 0.001)}).toList();

      // Spawn enemies
      if (_rand.nextInt(40) == 0) {
        _enemies.add({'x': _rand.nextDouble() * 0.9 + 0.05, 'y': -0.05});
      }

      // Check collisions
      for (var e in List.from(_enemies)) {
        for (var b in List.from(_bullets)) {
          if ((e['x']! - b['x']!).abs() < 0.05 && (e['y']! - b['y']!).abs() < 0.03) {
            _enemies.remove(e);
            _bullets.remove(b);
            _explosions.add({'x': e['x']!, 'y': e['y']!, 't': 10});
            _score += 10;
            _level = (_score ~/ 100) + 1;
            break;
          }
        }
        if ((e['x']! - _jetX).abs() < 0.06 && (e['y']! - _jetY).abs() < 0.04) {
          _gameOver = true;
          _timer?.cancel();
        }
        if (e['y']! > 1.1) {
          _enemies.remove(e);
        }
      }

      // Fade explosions
      _explosions = _explosions.map((e) => {'x': e['x']!, 'y': e['y']!, 't': e['t']! - 1}).where((e) => e['t']! > 0).toList();
    });
  }

  void _shoot() {
    if (_gameOver) return;
    _bullets.add({'x': _jetX, 'y': _jetY - 0.04});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Jet Shooter',
      score: _score,
      isGameOver: _gameOver,
      onRestart: () => setState(_startGame),
      accentColor: const Color(0xFFFF4500),
      child: GestureDetector(
        onPanUpdate: (d) {
          if (_gameOver) return;
          final size = MediaQuery.of(context).size;
          setState(() {
            _jetX = (d.localPosition.dx / size.width).clamp(0.05, 0.95);
            _jetY = (d.localPosition.dy / (size.height - 100)).clamp(0.3, 0.95);
          });
        },
        onTapDown: (_) => _shoot(),
        child: Container(
          color: Colors.transparent,
          child: CustomPaint(
            painter: _JetPainter(
              jetX: _jetX, jetY: _jetY,
              bullets: _bullets, enemies: _enemies, explosions: _explosions, level: _level,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _JetPainter extends CustomPainter {
  final double jetX, jetY;
  final List<Map<String, double>> bullets, enemies, explosions;
  final int level;
  _JetPainter({required this.jetX, required this.jetY, required this.bullets, required this.enemies, required this.explosions, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    // Stars background
    final starPaint = Paint()..color = Colors.white24;
    final rand = Random(42);
    for (int i = 0; i < 50; i++) {
      canvas.drawCircle(Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height), 1, starPaint);
    }

    // Jet
    final jetPaint = Paint()..color = const Color(0xFF00E5FF);
    final jx = jetX * size.width;
    final jy = jetY * size.height;
    final path = Path()
      ..moveTo(jx, jy - 20)
      ..lineTo(jx - 15, jy + 15)
      ..lineTo(jx, jy + 8)
      ..lineTo(jx + 15, jy + 15)
      ..close();
    canvas.drawPath(path, jetPaint);

    // Flame
    final flamePaint = Paint()..color = Colors.orange;
    canvas.drawOval(Rect.fromCenter(center: Offset(jx, jy + 18), width: 8, height: 12), flamePaint);

    // Bullets
    final bulletPaint = Paint()..color = Colors.yellowAccent;
    for (final b in bullets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(b['x']! * size.width, b['y']! * size.height), width: 4, height: 12), const Radius.circular(2)),
        bulletPaint,
      );
    }

    // Enemies
    final enemyPaint = Paint()..color = Colors.redAccent;
    for (final e in enemies) {
      final ex = e['x']! * size.width;
      final ey = e['y']! * size.height;
      final ePath = Path()
        ..moveTo(ex, ey + 15)
        ..lineTo(ex - 12, ey - 10)
        ..lineTo(ex, ey - 5)
        ..lineTo(ex + 12, ey - 10)
        ..close();
      canvas.drawPath(ePath, enemyPaint);
    }

    // Explosions
    for (final exp in explosions) {
      final opacity = (exp['t']! / 10).clamp(0.0, 1.0);
      final expPaint = Paint()..color = Colors.orange.withOpacity(opacity);
      canvas.drawCircle(Offset(exp['x']! * size.width, exp['y']! * size.height), 15 * (1 - opacity) + 5, expPaint);
    }

    // Level indicator
    final tp = TextPainter(
      text: TextSpan(text: 'LVL $level', style: TextStyle(color: Colors.white24, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width - 50, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
