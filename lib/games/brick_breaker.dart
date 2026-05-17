import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class BrickBreakerGame extends StatefulWidget {
  const BrickBreakerGame({super.key});
  @override
  State<BrickBreakerGame> createState() => _BrickBreakerGameState();
}

class _BrickBreakerGameState extends State<BrickBreakerGame> {
  double _paddleX = 0.5;
  double _ballX = 0.5, _ballY = 0.7;
  double _dx = 0.01, _dy = -0.012;
  int _score = 0;
  bool _gameOver = false;
  List<Rect> _bricks = [];
  List<Color> _brickColors = [];
  Timer? _timer;

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _paddleX = 0.5; _ballX = 0.5; _ballY = 0.7;
    _dx = 0.01; _dy = -0.012; _score = 0; _gameOver = false;
    _bricks = []; _brickColors = [];
    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple];
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        _bricks.add(Rect.fromLTWH(col / 7.0 + 0.01, row * 0.05 + 0.05, 1 / 7.0 - 0.02, 0.04));
        _brickColors.add(colors[row]);
      }
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), _tick);
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _ballX += _dx; _ballY += _dy;
      if (_ballX <= 0.01 || _ballX >= 0.99) _dx = -_dx;
      if (_ballY <= 0.02) _dy = -_dy;
      if (_ballY >= 0.92) {
        if ((_ballX - _paddleX).abs() < 0.1) {
          _dy = -_dy;
          _dx += (_ballX - _paddleX) * 0.05;
        } else {
          _gameOver = true; _timer?.cancel();
        }
      }
      for (int i = _bricks.length - 1; i >= 0; i--) {
        final b = _bricks[i];
        if (_ballX >= b.left && _ballX <= b.right && _ballY >= b.top && _ballY <= b.bottom) {
          _bricks.removeAt(i); _brickColors.removeAt(i);
          _dy = -_dy; _score += 10; break;
        }
      }
      if (_bricks.isEmpty) { _gameOver = true; _timer?.cancel(); _score += 100; }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Brick Breaker', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFFE91E63),
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() => _paddleX = (d.localPosition.dx / MediaQuery.of(context).size.width).clamp(0.1, 0.9));
        },
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _BrickPainter(paddleX: _paddleX, ballX: _ballX, ballY: _ballY, bricks: _bricks, brickColors: _brickColors),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _BrickPainter extends CustomPainter {
  final double paddleX, ballX, ballY;
  final List<Rect> bricks;
  final List<Color> brickColors;
  _BrickPainter({required this.paddleX, required this.ballX, required this.ballY, required this.bricks, required this.brickColors});

  @override
  void paint(Canvas canvas, Size size) {
    // Bricks
    for (int i = 0; i < bricks.length; i++) {
      final b = bricks[i];
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(b.left * size.width, b.top * size.height, b.width * size.width, b.height * size.height), const Radius.circular(3)),
        Paint()..color = brickColors[i]);
    }
    // Paddle
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(paddleX * size.width, size.height * 0.93), width: size.width * 0.2, height: 12), const Radius.circular(6)),
      Paint()..color = const Color(0xFF00E5FF));
    // Ball
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 8, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 12, Paint()..color = Colors.white.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
