import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});
  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const _cols = 10, _rows = 20;
  List<List<Color?>> _grid = List.generate(_rows, (_) => List.filled(_cols, null));
  List<Point<int>> _current = [];
  Color _currentColor = Colors.cyan;
  int _score = 0;
  bool _gameOver = false;
  Timer? _timer;
  final _rand = Random();

  final _pieces = [
    [Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0)], // I
    [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)], // O
    [Point(0, 0), Point(1, 0), Point(2, 0), Point(1, 1)], // T
    [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)], // S
    [Point(1, 0), Point(2, 0), Point(0, 1), Point(1, 1)], // Z
    [Point(0, 0), Point(0, 1), Point(1, 1), Point(2, 1)], // L
    [Point(2, 0), Point(0, 1), Point(1, 1), Point(2, 1)], // J
  ];
  final _pieceColors = [Colors.cyan, Colors.yellow, Colors.purple, Colors.green, Colors.red, Colors.orange, Colors.blue];

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _grid = List.generate(_rows, (_) => List.filled(_cols, null));
    _score = 0; _gameOver = false;
    _spawnPiece();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _moveDown());
    setState(() {});
  }

  void _spawnPiece() {
    final idx = _rand.nextInt(_pieces.length);
    _currentColor = _pieceColors[idx];
    _current = _pieces[idx].map((p) => Point(p.x + 3, p.y)).toList();
    if (_current.any((p) => _grid[p.y][p.x] != null)) { _gameOver = true; _timer?.cancel(); }
  }

  bool _canMove(List<Point<int>> pts) => pts.every((p) => p.x >= 0 && p.x < _cols && p.y >= 0 && p.y < _rows && _grid[p.y][p.x] == null);

  void _moveDown() {
    if (_gameOver) return;
    final next = _current.map((p) => Point(p.x, p.y + 1)).toList();
    if (_canMove(next)) { setState(() => _current = next); }
    else { _lock(); }
  }

  void _lock() {
    for (var p in _current) _grid[p.y][p.x] = _currentColor;
    _clearLines();
    _spawnPiece();
    setState(() {});
  }

  void _clearLines() {
    for (int r = _rows - 1; r >= 0; r--) {
      if (_grid[r].every((c) => c != null)) {
        _grid.removeAt(r);
        _grid.insert(0, List.filled(_cols, null));
        _score += 100;
        r++;
      }
    }
  }

  void _moveLeft() {
    final next = _current.map((p) => Point(p.x - 1, p.y)).toList();
    if (_canMove(next)) setState(() => _current = next);
  }

  void _moveRight() {
    final next = _current.map((p) => Point(p.x + 1, p.y)).toList();
    if (_canMove(next)) setState(() => _current = next);
  }

  void _rotate() {
    if (_current.isEmpty) return;
    final cx = _current[0].x, cy = _current[0].y;
    final rotated = _current.map((p) => Point(cx + cy - p.y, cy - cx + p.x)).toList();
    if (_canMove(rotated)) setState(() => _current = rotated);
  }

  void _drop() { while (_canMove(_current.map((p) => Point(p.x, p.y + 1)).toList())) { _current = _current.map((p) => Point(p.x, p.y + 1)).toList(); } _lock(); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Tetris', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFF3F51B5),
      child: Column(children: [
        Expanded(child: Center(child: AspectRatio(aspectRatio: _cols / _rows, child: CustomPaint(
          painter: _TetrisPainter(grid: _grid, current: _current, currentColor: _currentColor, cols: _cols, rows: _rows),
          size: Size.infinite,
        )))),
        Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(onPressed: _moveLeft, icon: const Icon(Icons.arrow_left, color: Colors.white70, size: 36)),
          IconButton(onPressed: _rotate, icon: const Icon(Icons.rotate_right, color: Colors.white70, size: 36)),
          IconButton(onPressed: _drop, icon: const Icon(Icons.arrow_downward, color: Colors.white70, size: 36)),
          IconButton(onPressed: _moveRight, icon: const Icon(Icons.arrow_right, color: Colors.white70, size: 36)),
        ])),
      ]),
    );
  }
}

class _TetrisPainter extends CustomPainter {
  final List<List<Color?>> grid;
  final List<Point<int>> current;
  final Color currentColor;
  final int cols, rows;
  _TetrisPainter({required this.grid, required this.current, required this.currentColor, required this.cols, required this.rows});

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols, cellH = size.height / rows;
    // Grid bg
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0D0D1A));
    // Grid lines
    for (int c = 0; c <= cols; c++) canvas.drawLine(Offset(c * cellW, 0), Offset(c * cellW, size.height), Paint()..color = Colors.white.withOpacity(0.05));
    for (int r = 0; r <= rows; r++) canvas.drawLine(Offset(0, r * cellH), Offset(size.width, r * cellH), Paint()..color = Colors.white.withOpacity(0.05));
    // Placed blocks
    for (int r = 0; r < rows; r++) for (int c = 0; c < cols; c++) {
      if (grid[r][c] != null) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(c * cellW + 1, r * cellH + 1, cellW - 2, cellH - 2), const Radius.circular(2)), Paint()..color = grid[r][c]!);
      }
    }
    // Current piece
    for (var p in current) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.x * cellW + 1, p.y * cellH + 1, cellW - 2, cellH - 2), const Radius.circular(2)), Paint()..color = currentColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
