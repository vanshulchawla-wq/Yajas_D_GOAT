import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});
  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> {
  double _birdY = 0.5;
  double _velocity = 0;
  int _score = 0;
  bool _gameOver = false;
  bool _started = false;
  List<double> _pipeX = [];
  List<double> _pipeGap = [];
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _reset(); }

  void _reset() {
    _birdY = 0.5; _velocity = 0; _score = 0; _gameOver = false; _started = false;
    _pipeX = [1.0, 1.6, 2.2];
    _pipeGap = List.generate(3, (_) => _rand.nextDouble() * 0.3 + 0.3);
  }

  void _start() {
    _started = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _velocity += 0.0012;
      _birdY += _velocity;

      if (_birdY > 1 || _birdY < 0) { _gameOver = true; _timer?.cancel(); return; }

      for (int i = 0; i < _pipeX.length; i++) {
        _pipeX[i] -= 0.008;
        if (_pipeX[i] < -0.15) {
          _pipeX[i] = _pipeX.reduce(max) + 0.6;
          _pipeGap[i] = _rand.nextDouble() * 0.3 + 0.3;
          _score += 10;
        }
        // Collision
        if ((_pipeX[i] - 0.15).abs() < 0.06) {
          final gap = _pipeGap[i];
          if (_birdY < gap - 0.01 || _birdY > gap + 0.18) {
            _gameOver = true; _timer?.cancel();
          }
        }
      }
    });
  }

  void _flap() {
    if (_gameOver) return;
    if (!_started) _start();
    setState(() => _velocity = -0.018);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Flappy Bird', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(() { _reset(); }),
      accentColor: const Color(0xFFFFEB3B),
      child: GestureDetector(
        onTap: _flap,
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _FlappyPainter(birdY: _birdY, pipeX: _pipeX, pipeGap: _pipeGap, started: _started),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _FlappyPainter extends CustomPainter {
  final double birdY;
  final List<double> pipeX;
  final List<double> pipeGap;
  final bool started;
  _FlappyPainter({required this.birdY, required this.pipeX, required this.pipeGap, required this.started});

  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF4CAF50)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Ground
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08), Paint()..color = const Color(0xFF33691E));

    // Pipes
    final pipePaint = Paint()..color = const Color(0xFF2E7D32);
    final pipeEdge = Paint()..color = const Color(0xFF1B5E20);
    for (int i = 0; i < pipeX.length; i++) {
      final px = pipeX[i] * size.width;
      final gapTop = pipeGap[i] * size.height;
      final gapBot = gapTop + size.height * 0.18;
      // Top pipe
      canvas.drawRect(Rect.fromLTWH(px, 0, 50, gapTop), pipePaint);
      canvas.drawRect(Rect.fromLTWH(px - 5, gapTop - 20, 60, 20), pipeEdge);
      // Bottom pipe
      canvas.drawRect(Rect.fromLTWH(px, gapBot, 50, size.height - gapBot), pipePaint);
      canvas.drawRect(Rect.fromLTWH(px - 5, gapBot, 60, 20), pipeEdge);
    }

    // Bird
    final bx = size.width * 0.15;
    final by = birdY * size.height;
    canvas.drawCircle(Offset(bx, by), 16, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawCircle(Offset(bx + 8, by - 4), 5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(bx + 9, by - 4), 2.5, Paint()..color = Colors.black);
    // Wing
    canvas.drawOval(Rect.fromCenter(center: Offset(bx - 5, by + 2), width: 14, height: 8), Paint()..color = const Color(0xFFF57F17));

    if (!started) {
      final tp = TextPainter(text: const TextSpan(text: 'TAP TO START', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
