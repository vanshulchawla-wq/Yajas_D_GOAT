import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class SpaceInvadersGame extends StatefulWidget {
  const SpaceInvadersGame({super.key});
  @override
  State<SpaceInvadersGame> createState() => _SpaceInvadersGameState();
}

class _SpaceInvadersGameState extends State<SpaceInvadersGame> {
  double _shipX = 0.5;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _invaders = [];
  List<Map<String, double>> _bullets = [];
  List<Map<String, double>> _enemyBullets = [];
  double _invaderDir = 0.003;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _shipX = 0.5; _score = 0; _gameOver = false;
    _bullets = []; _enemyBullets = [];
    _invaders = [];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 8; c++) {
        _invaders.add({'x': c * 0.1 + 0.15, 'y': r * 0.06 + 0.08});
      }
    }
    _invaderDir = 0.003;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), _tick);
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      // Move invaders
      bool hitEdge = false;
      for (var inv in _invaders) {
        inv['x'] = inv['x']! + _invaderDir;
        if (inv['x']! < 0.05 || inv['x']! > 0.95) hitEdge = true;
      }
      if (hitEdge) {
        _invaderDir = -_invaderDir;
        for (var inv in _invaders) inv['y'] = inv['y']! + 0.02;
      }

      // Move bullets
      _bullets = _bullets.map((b) => {'x': b['x']!, 'y': b['y']! - 0.02}).where((b) => b['y']! > 0).toList();
      _enemyBullets = _enemyBullets.map((b) => {'x': b['x']!, 'y': b['y']! + 0.012}).where((b) => b['y']! < 1).toList();

      // Enemy shoots
      if (_rand.nextInt(60) == 0 && _invaders.isNotEmpty) {
        final shooter = _invaders[_rand.nextInt(_invaders.length)];
        _enemyBullets.add({'x': shooter['x']!, 'y': shooter['y']! + 0.03});
      }

      // Bullet-invader collision
      for (var b in List.from(_bullets)) {
        for (var inv in List.from(_invaders)) {
          if ((b['x']! - inv['x']!).abs() < 0.04 && (b['y']! - inv['y']!).abs() < 0.03) {
            _bullets.remove(b); _invaders.remove(inv); _score += 15; break;
          }
        }
      }

      // Enemy bullet hits player
      for (var eb in _enemyBullets) {
        if ((eb['x']! - _shipX).abs() < 0.05 && eb['y']! > 0.88) {
          _gameOver = true; _timer?.cancel(); return;
        }
      }

      // Invaders reach bottom
      if (_invaders.any((i) => i['y']! > 0.85)) { _gameOver = true; _timer?.cancel(); }
      if (_invaders.isEmpty) { _score += 100; _startGame(); }
    });
  }

  void _shoot() { if (!_gameOver) _bullets.add({'x': _shipX, 'y': 0.87}); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Space Invaders', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF9C27B0),
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _shipX = (d.localPosition.dx / MediaQuery.of(context).size.width).clamp(0.05, 0.95)),
        onTapDown: (_) => _shoot(),
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _InvaderPainter(shipX: _shipX, invaders: _invaders, bullets: _bullets, enemyBullets: _enemyBullets),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _InvaderPainter extends CustomPainter {
  final double shipX;
  final List<Map<String, double>> invaders, bullets, enemyBullets;
  _InvaderPainter({required this.shipX, required this.invaders, required this.bullets, required this.enemyBullets});

  @override
  void paint(Canvas canvas, Size size) {
    // Ship
    final sx = shipX * size.width;
    final sy = size.height * 0.9;
    final path = Path()..moveTo(sx, sy - 15)..lineTo(sx - 18, sy + 10)..lineTo(sx + 18, sy + 10)..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF00E5FF));

    // Invaders
    for (final inv in invaders) {
      final ix = inv['x']! * size.width;
      final iy = inv['y']! * size.height;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ix, iy), width: 24, height: 18), const Radius.circular(4)),
        Paint()..color = const Color(0xFF9C27B0));
      canvas.drawCircle(Offset(ix - 5, iy - 2), 3, Paint()..color = Colors.yellowAccent);
      canvas.drawCircle(Offset(ix + 5, iy - 2), 3, Paint()..color = Colors.yellowAccent);
    }

    // Bullets
    for (final b in bullets) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(b['x']! * size.width, b['y']! * size.height), width: 3, height: 10), const Radius.circular(2)),
        Paint()..color = Colors.greenAccent);
    }
    for (final b in enemyBullets) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(b['x']! * size.width, b['y']! * size.height), width: 3, height: 10), const Radius.circular(2)),
        Paint()..color = Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
