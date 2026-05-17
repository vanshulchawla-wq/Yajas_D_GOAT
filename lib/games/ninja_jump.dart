import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class NinjaJumpGame extends StatefulWidget {
  const NinjaJumpGame({super.key});
  @override
  State<NinjaJumpGame> createState() => _NinjaJumpGameState();
}

class _NinjaJumpGameState extends State<NinjaJumpGame> {
  double _ninjaX = 0.5, _ninjaY = 0.7;
  double _vy = -0.025;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _platforms = [];
  List<Map<String, double>> _shurikens = [];
  Timer? _timer;
  final _rand = Random();
  bool _facingRight = true;

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _ninjaX = 0.5; _ninjaY = 0.7; _vy = -0.025; _score = 0; _gameOver = false;
    _platforms = [{'x': 0.3, 'y': 0.85, 'w': 0.4, 'type': 0}];
    for (int i = 1; i < 12; i++) {
      _platforms.add({'x': _rand.nextDouble() * 0.6 + 0.1, 'y': 0.85 - i * 0.1, 'w': _rand.nextDouble() * 0.15 + 0.15, 'type': _rand.nextInt(3).toDouble()});
    }
    _shurikens = [];
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _vy += 0.001;
      _ninjaY += _vy;

      // Platform collision (only when falling)
      if (_vy > 0) {
        for (var p in _platforms) {
          if (_ninjaX >= p['x']! - 0.03 && _ninjaX <= p['x']! + p['w']! + 0.03 &&
              _ninjaY >= p['y']! - 0.02 && _ninjaY <= p['y']! + 0.01) {
            _vy = p['type'] == 1 ? -0.035 : -0.025; // Spring platform
            if (p['type'] == 2) p['w'] = 0; // Breakable
          }
        }
      }

      // Scroll when ninja goes above middle
      if (_ninjaY < 0.4) {
        final shift = 0.4 - _ninjaY;
        _ninjaY = 0.4;
        for (var p in _platforms) p['y'] = p['y']! + shift;
        for (var s in _shurikens) s['y'] = s['y']! + shift;
        _score += (shift * 100).toInt();
      }

      // Remove off-screen platforms, add new
      _platforms.removeWhere((p) => p['y']! > 1.1 || p['w'] == 0);
      while (_platforms.length < 12) {
        final topY = _platforms.map((p) => p['y']!).reduce(min) - 0.1;
        _platforms.add({'x': _rand.nextDouble() * 0.6 + 0.1, 'y': topY, 'w': _rand.nextDouble() * 0.15 + 0.15, 'type': _rand.nextInt(3).toDouble()});
      }

      // Spawn shurikens
      if (_rand.nextInt(100) == 0) {
        _shurikens.add({'x': _rand.nextBool() ? -0.05 : 1.05, 'y': _rand.nextDouble() * 0.5 + 0.2, 'dx': _rand.nextBool() ? 0.01 : -0.01});
      }
      _shurikens = _shurikens.map((s) => {'x': s['x']! + s['dx']!, 'y': s['y']!, 'dx': s['dx']!}).where((s) => s['x']! > -0.1 && s['x']! < 1.1).toList();

      // Shuriken collision
      for (var s in _shurikens) {
        if ((s['x']! - _ninjaX).abs() < 0.04 && (s['y']! - _ninjaY).abs() < 0.04) {
          _gameOver = true; _timer?.cancel();
        }
      }

      // Fall off screen
      if (_ninjaY > 1.1) { _gameOver = true; _timer?.cancel(); }

      // Wrap horizontal
      if (_ninjaX < 0) _ninjaX = 1.0;
      if (_ninjaX > 1) _ninjaX = 0.0;
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Ninja Jump', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF212121),
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _ninjaX += d.delta.dx / MediaQuery.of(context).size.width;
            _facingRight = d.delta.dx > 0;
          });
        },
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _NinjaPainter(ninjaX: _ninjaX, ninjaY: _ninjaY, platforms: _platforms, shurikens: _shurikens, facingRight: _facingRight),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _NinjaPainter extends CustomPainter {
  final double ninjaX, ninjaY;
  final List<Map<String, double>> platforms, shurikens;
  final bool facingRight;
  _NinjaPainter({required this.ninjaX, required this.ninjaY, required this.platforms, required this.shurikens, required this.facingRight});

  @override
  void paint(Canvas canvas, Size size) {
    // Platforms
    final platColors = [const Color(0xFF4CAF50), const Color(0xFFFF9800), const Color(0xFF9E9E9E)];
    for (var p in platforms) {
      if (p['w']! <= 0) continue;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(p['x']! * size.width, p['y']! * size.height, p['w']! * size.width, 8), const Radius.circular(4)),
        Paint()..color = platColors[p['type']!.toInt()]);
    }

    // Ninja
    final nx = ninjaX * size.width, ny = ninjaY * size.height;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(nx, ny), width: 20, height: 28), const Radius.circular(4)), Paint()..color = const Color(0xFF212121));
    // Headband
    canvas.drawRect(Rect.fromLTWH(nx - 12, ny - 10, 24, 4), Paint()..color = Colors.red);
    // Eyes
    canvas.drawCircle(Offset(nx + (facingRight ? 4 : -4), ny - 4), 3, Paint()..color = Colors.white);

    // Shurikens
    for (var s in shurikens) {
      final sx = s['x']! * size.width, sy = s['y']! * size.height;
      canvas.drawCircle(Offset(sx, sy), 8, Paint()..color = Colors.grey);
      for (int i = 0; i < 4; i++) {
        final angle = i * 3.14159 / 2;
        canvas.drawLine(Offset(sx, sy), Offset(sx + cos(angle) * 10, sy + sin(angle) * 10), Paint()..color = Colors.white54..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
