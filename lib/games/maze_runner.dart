import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class MazeRunnerGame extends StatefulWidget {
  const MazeRunnerGame({super.key});
  @override
  State<MazeRunnerGame> createState() => _MazeRunnerGameState();
}

class _MazeRunnerGameState extends State<MazeRunnerGame> {
  static const _size = 11;
  late List<List<bool>> _walls;
  int _px = 1, _py = 1;
  int _ex = _size - 2, _ey = _size - 2;
  int _score = 0;
  int _level = 1;
  int _moves = 0;
  bool _gameOver = false;

  @override
  void initState() { super.initState(); _generateMaze(); }

  void _generateMaze() {
    _walls = List.generate(_size, (r) => List.generate(_size, (c) => true));
    _px = 1; _py = 1; _ex = _size - 2; _ey = _size - 2; _moves = 0;
    // Simple maze generation using recursive backtracker
    final visited = List.generate(_size, (_) => List.filled(_size, false));
    final stack = <Point<int>>[];
    final rand = Random();
    void carve(int x, int y) {
      visited[y][x] = true; _walls[y][x] = false;
      final dirs = [Point(0, -2), Point(0, 2), Point(-2, 0), Point(2, 0)]..shuffle(rand);
      for (final d in dirs) {
        final nx = x + d.x, ny = y + d.y;
        if (nx > 0 && nx < _size - 1 && ny > 0 && ny < _size - 1 && !visited[ny][nx]) {
          _walls[y + d.y ~/ 2][x + d.x ~/ 2] = false;
          carve(nx, ny);
        }
      }
    }
    carve(1, 1);
    _walls[_ey][_ex] = false;
    setState(() {});
  }

  void _move(int dx, int dy) {
    if (_gameOver) return;
    final nx = _px + dx, ny = _py + dy;
    if (nx >= 0 && nx < _size && ny >= 0 && ny < _size && !_walls[ny][nx]) {
      setState(() {
        _px = nx; _py = ny; _moves++;
        if (_px == _ex && _py == _ey) {
          _score += max(10, 50 - _moves);
          _level++;
          _generateMaze();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Maze Runner', score: _score, isGameOver: _gameOver,
      onRestart: () { _score = 0; _level = 1; _gameOver = false; _generateMaze(); },
      accentColor: const Color(0xFF009688),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Level $_level • Moves: $_moves', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13))),
        Expanded(child: Center(child: AspectRatio(aspectRatio: 1, child: GestureDetector(
          onVerticalDragEnd: (d) => _move(0, (d.primaryVelocity ?? 0) > 0 ? 1 : -1),
          onHorizontalDragEnd: (d) => _move((d.primaryVelocity ?? 0) > 0 ? 1 : -1, 0),
          child: CustomPaint(
            painter: _MazePainter(walls: _walls, px: _px, py: _py, ex: _ex, ey: _ey, size: _size),
            size: Size.infinite,
          ),
        )))),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _btn(Icons.arrow_upward, () => _move(0, -1)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _btn(Icons.arrow_back, () => _move(-1, 0)),
            const SizedBox(width: 48),
            _btn(Icons.arrow_forward, () => _move(1, 0)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _btn(Icons.arrow_downward, () => _move(0, 1)),
          ]),
        ])),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => IconButton(
    onPressed: onTap, icon: Icon(icon, color: Colors.white70, size: 32),
    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
  );
}

class _MazePainter extends CustomPainter {
  final List<List<bool>> walls;
  final int px, py, ex, ey, size;
  _MazePainter({required this.walls, required this.px, required this.py, required this.ex, required this.ey, required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    final cell = s.width / size;
    for (int r = 0; r < size; r++) for (int c = 0; c < size; c++) {
      final color = walls[r][c] ? const Color(0xFF1A237E) : const Color(0xFF0D0D1A);
      canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), Paint()..color = color);
    }
    // Exit
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ex * cell + 2, ey * cell + 2, cell - 4, cell - 4), const Radius.circular(4)), Paint()..color = Colors.greenAccent);
    // Player
    canvas.drawCircle(Offset(px * cell + cell / 2, py * cell + cell / 2), cell / 2 - 3, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(px * cell + cell / 2, py * cell + cell / 2), cell / 2, Paint()..color = const Color(0xFF00E5FF).withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
