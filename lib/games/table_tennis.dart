import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class TableTennisGame extends StatefulWidget {
  const TableTennisGame({super.key});
  @override
  State<TableTennisGame> createState() => _TableTennisGameState();
}

class _TableTennisGameState extends State<TableTennisGame> {
  double _playerX = 0.5;
  double _aiX = 0.5;
  double _ballX = 0.5, _ballY = 0.5;
  double _ballDX = 0.012, _ballDY = 0.015;
  int _score = 0;
  int _aiScore = 0;
  bool _gameOver = false;
  Timer? _timer;
  double _aiSpeed = 0.015;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _aiScore = 0;
    _gameOver = false;
    _ballX = 0.5;
    _ballY = 0.5;
    _ballDX = (Random().nextBool() ? 1 : -1) * 0.012;
    _ballDY = 0.015;
    _aiSpeed = 0.015;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), _tick);
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _ballX += _ballDX;
      _ballY += _ballDY;

      // Wall bounce
      if (_ballX <= 0.02 || _ballX >= 0.98) _ballDX = -_ballDX;

      // Player paddle (bottom)
      if (_ballY >= 0.9 && _ballDY > 0) {
        if ((_ballX - _playerX).abs() < 0.12) {
          _ballDY = -_ballDY;
          _ballDX += (_ballX - _playerX) * 0.05;
          _score += 5;
          _aiSpeed = min(0.03, _aiSpeed + 0.001);
        } else {
          _aiScore++;
          _resetBall();
        }
      }

      // AI paddle (top)
      if (_ballY <= 0.1 && _ballDY < 0) {
        if ((_ballX - _aiX).abs() < 0.12) {
          _ballDY = -_ballDY;
          _ballDX += (_ballX - _aiX) * 0.03;
        } else {
          _score += 15;
          _resetBall();
        }
      }

      // AI movement
      if (_aiX < _ballX - 0.02) _aiX += _aiSpeed;
      if (_aiX > _ballX + 0.02) _aiX -= _aiSpeed;
      _aiX = _aiX.clamp(0.1, 0.9);

      // Game over at 5 AI points
      if (_aiScore >= 5) {
        _gameOver = true;
        _timer?.cancel();
      }
    });
  }

  void _resetBall() {
    _ballX = 0.5;
    _ballY = 0.5;
    _ballDX = (Random().nextBool() ? 1 : -1) * 0.012;
    _ballDY = (Random().nextBool() ? 1 : -1) * 0.015;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Table Tennis',
      score: _score,
      isGameOver: _gameOver,
      onRestart: () => setState(_startGame),
      accentColor: const Color(0xFF00C853),
      child: GestureDetector(
        onPanUpdate: (d) {
          final w = MediaQuery.of(context).size.width;
          setState(() => _playerX = (d.localPosition.dx / w).clamp(0.1, 0.9));
        },
        child: Container(
          color: Colors.transparent,
          child: CustomPaint(
            painter: _TennisPainter(playerX: _playerX, aiX: _aiX, ballX: _ballX, ballY: _ballY, score: _score, aiScore: _aiScore),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _TennisPainter extends CustomPainter {
  final double playerX, aiX, ballX, ballY;
  final int score, aiScore;
  _TennisPainter({required this.playerX, required this.aiX, required this.ballX, required this.ballY, required this.score, required this.aiScore});

  @override
  void paint(Canvas canvas, Size size) {
    // Table
    final tablePaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), const Radius.circular(8)), tablePaint);

    // Net
    final netPaint = Paint()..color = Colors.white24..strokeWidth = 2;
    canvas.drawLine(Offset(20, size.height / 2), Offset(size.width - 20, size.height / 2), netPaint);

    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 2);

    // Player paddle
    final paddlePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(playerX * size.width, size.height * 0.9), width: size.width * 0.22, height: 14),
      const Radius.circular(7),
    ), paddlePaint);

    // AI paddle
    final aiPaint = Paint()..color = const Color(0xFFFF4500);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(aiX * size.width, size.height * 0.1), width: size.width * 0.22, height: 14),
      const Radius.circular(7),
    ), aiPaint);

    // Ball
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 10, ballPaint);
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 10, Paint()..color = Colors.yellowAccent.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Score display
    final tp1 = TextPainter(text: TextSpan(text: '$aiScore', style: const TextStyle(color: Colors.white24, fontSize: 40)), textDirection: TextDirection.ltr)..layout();
    tp1.paint(canvas, Offset(size.width / 2 - tp1.width / 2, size.height * 0.3));
    final tp2 = TextPainter(text: TextSpan(text: '$score', style: const TextStyle(color: Colors.white24, fontSize: 40)), textDirection: TextDirection.ltr)..layout();
    tp2.paint(canvas, Offset(size.width / 2 - tp2.width / 2, size.height * 0.6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
