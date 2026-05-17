import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class FruitNinjaGame extends StatefulWidget {
  const FruitNinjaGame({super.key});
  @override
  State<FruitNinjaGame> createState() => _FruitNinjaGameState();
}

class _FruitNinjaGameState extends State<FruitNinjaGame> {
  final _fruits = ['🍎', '🍊', '🍋', '🍇', '🍉', '🍓', '🥝', '🍑'];
  List<Map<String, dynamic>> _active = [];
  List<Offset> _sliceTrail = [];
  int _score = 0;
  int _lives = 3;
  bool _gameOver = false;
  Timer? _timer, _spawnTimer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _active = []; _sliceTrail = []; _score = 0; _lives = 3; _gameOver = false;
    _timer?.cancel(); _spawnTimer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), _tick);
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), _spawn);
    setState(() {});
  }

  void _spawn(Timer t) {
    if (_gameOver) return;
    setState(() {
      _active.add({
        'emoji': _rand.nextInt(10) == 0 ? '💣' : _fruits[_rand.nextInt(_fruits.length)],
        'x': _rand.nextDouble() * 0.8 + 0.1,
        'y': 1.1,
        'vx': (_rand.nextDouble() - 0.5) * 0.01,
        'vy': -0.025 - _rand.nextDouble() * 0.01,
        'sliced': false,
      });
    });
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      for (var f in _active) {
        f['x'] += f['vx'];
        f['vy'] += 0.0008;
        f['y'] += f['vy'];
      }
      // Remove fallen fruits (missed)
      final fallen = _active.where((f) => f['y'] > 1.2 && !f['sliced'] && f['emoji'] != '💣').toList();
      for (var f in fallen) { _lives--; }
      _active.removeWhere((f) => f['y'] > 1.2);
      if (_lives <= 0) { _gameOver = true; _timer?.cancel(); _spawnTimer?.cancel(); }
      // Fade trail
      if (_sliceTrail.length > 15) _sliceTrail.removeAt(0);
    });
  }

  void _onSlice(Offset pos, Size size) {
    if (_gameOver) return;
    final nx = pos.dx / size.width;
    final ny = pos.dy / size.height;
    _sliceTrail.add(pos);
    for (var f in _active) {
      if (f['sliced']) continue;
      if ((f['x'] - nx).abs() < 0.07 && (f['y'] - ny).abs() < 0.05) {
        f['sliced'] = true;
        if (f['emoji'] == '💣') { _lives--; if (_lives <= 0) { _gameOver = true; _timer?.cancel(); _spawnTimer?.cancel(); } }
        else { _score += 10; }
      }
    }
    setState(() {});
  }

  @override
  void dispose() { _timer?.cancel(); _spawnTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Fruit Ninja', score: _score, isGameOver: _gameOver,
      onRestart: _startGame, accentColor: const Color(0xFFF44336),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanUpdate: (d) => _onSlice(d.localPosition, size),
          onPanEnd: (_) => _sliceTrail.clear(),
          child: Container(color: Colors.transparent, child: CustomPaint(
            painter: _FruitPainter(active: _active, trail: _sliceTrail, lives: _lives, size: size),
            size: Size.infinite,
          )),
        );
      }),
    );
  }
}

class _FruitPainter extends CustomPainter {
  final List<Map<String, dynamic>> active;
  final List<Offset> trail;
  final int lives;
  final Size size;
  _FruitPainter({required this.active, required this.trail, required this.lives, required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    // Slice trail
    if (trail.length > 1) {
      final path = Path()..moveTo(trail.first.dx, trail.first.dy);
      for (final p in trail.skip(1)) path.lineTo(p.dx, p.dy);
      canvas.drawPath(path, Paint()..color = Colors.white..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    }
    // Fruits
    for (final f in active) {
      final tp = TextPainter(text: TextSpan(text: f['sliced'] ? '💥' : f['emoji'], style: const TextStyle(fontSize: 36)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(f['x'] * s.width - 18, f['y'] * s.height - 18));
    }
    // Lives
    for (int i = 0; i < lives; i++) {
      final tp = TextPainter(text: const TextSpan(text: '❤️', style: TextStyle(fontSize: 20)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(10 + i * 28.0, s.height - 30));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
