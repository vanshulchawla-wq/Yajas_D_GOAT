import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});
  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const _gridSize = 20;
  List<Point<int>> _snake = [const Point(10, 10)];
  Point<int> _food = const Point(15, 15);
  Point<int> _dir = const Point(1, 0);
  int _score = 0;
  bool _gameOver = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
    _dir = const Point(1, 0);
    _score = 0;
    _gameOver = false;
    _spawnFood();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 150), _tick);
  }

  void _spawnFood() {
    final r = Random();
    do {
      _food = Point(r.nextInt(_gridSize), r.nextInt(_gridSize));
    } while (_snake.contains(_food));
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      final head = Point(_snake.first.x + _dir.x, _snake.first.y + _dir.y);
      if (head.x < 0 || head.x >= _gridSize || head.y < 0 || head.y >= _gridSize || _snake.contains(head)) {
        _gameOver = true;
        _timer?.cancel();
        return;
      }
      _snake.insert(0, head);
      if (head == _food) {
        _score += 10;
        _spawnFood();
      } else {
        _snake.removeLast();
      }
    });
  }

  void _changeDir(Point<int> newDir) {
    if (_dir.x + newDir.x != 0 || _dir.y + newDir.y != 0) _dir = newDir;
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Snake', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF4CAF50),
      child: GestureDetector(
        onVerticalDragUpdate: (d) => _changeDir(d.delta.dy < 0 ? const Point(0, -1) : const Point(0, 1)),
        onHorizontalDragUpdate: (d) => _changeDir(d.delta.dx < 0 ? const Point(-1, 0) : const Point(1, 0)),
        child: Container(
          color: Colors.transparent,
          child: Center(child: AspectRatio(aspectRatio: 1, child: CustomPaint(
            painter: _SnakePainter(snake: _snake, food: _food, gridSize: _gridSize),
            size: Size.infinite,
          ))),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;
  _SnakePainter({required this.snake, required this.food, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / gridSize;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0D1B0D));
    // Grid
    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), Paint()..color = Colors.white.withOpacity(0.03));
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), Paint()..color = Colors.white.withOpacity(0.03));
    }
    // Snake
    for (int i = 0; i < snake.length; i++) {
      final opacity = 1.0 - (i / snake.length) * 0.5;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(snake[i].x * cell + 1, snake[i].y * cell + 1, cell - 2, cell - 2), const Radius.circular(4)),
        Paint()..color = Color.lerp(const Color(0xFF00E676), const Color(0xFF1B5E20), i / snake.length)!.withOpacity(opacity),
      );
    }
    // Food
    canvas.drawCircle(Offset(food.x * cell + cell / 2, food.y * cell + cell / 2), cell / 2 - 2, Paint()..color = Colors.redAccent);
    canvas.drawCircle(Offset(food.x * cell + cell / 2, food.y * cell + cell / 2), cell / 2, Paint()..color = Colors.red.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
