import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_scaffold.dart';

class CoinCollectorGame extends StatefulWidget {
  const CoinCollectorGame({super.key});
  @override
  State<CoinCollectorGame> createState() => _CoinCollectorGameState();
}

class _CoinCollectorGameState extends State<CoinCollectorGame> {
  double _playerX = 0.5, _playerY = 0.8;
  double _vy = 0;
  bool _onGround = true;
  int _score = 0;
  bool _gameOver = false;
  List<Map<String, double>> _coins = [];
  List<Map<String, double>> _platforms = [];
  double _scrollOffset = 0;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _playerX = 0.5; _playerY = 0.8; _vy = 0; _onGround = true;
    _score = 0; _gameOver = false; _scrollOffset = 0;
    _platforms = [{'x': 0.0, 'y': 0.9, 'w': 1.0}];
    for (int i = 1; i < 10; i++) {
      _platforms.add({'x': _rand.nextDouble() * 0.6, 'y': 0.9 - i * 0.12, 'w': _rand.nextDouble() * 0.2 + 0.2});
    }
    _coins = _platforms.skip(1).map((p) => {'x': p['x']! + p['w']! / 2, 'y': p['y']! - 0.05}).toList();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      _vy += 0.0015;
      _playerY += _vy;
      _onGround = false;

      for (var p in _platforms) {
        if (_vy > 0 && _playerX >= p['x']! - 0.03 && _playerX <= p['x']! + p['w']! + 0.03 &&
            _playerY >= p['y']! - 0.02 && _playerY <= p['y']! + 0.02) {
          _playerY = p['y']! - 0.01; _vy = 0; _onGround = true;
        }
      }

      // Collect coins
      for (var c in List.from(_coins)) {
        if ((_playerX - c['x']!).abs() < 0.05 && (_playerY - c['y']!).abs() < 0.05) {
          _coins.remove(c); _score += 10;
        }
      }

      // Scroll up when player goes above middle
      if (_playerY < 0.4) {
        final shift = 0.4 - _playerY;
        _playerY = 0.4;
        for (var p in _platforms) p['y'] = p['y']! + shift;
        for (var c in _coins) c['y'] = c['y']! + shift;
        _scrollOffset += shift;
        // Remove off-screen, add new
        _platforms.removeWhere((p) => p['y']! > 1.1);
        _coins.removeWhere((c) => c['y']! > 1.1);
        while (_platforms.length < 10) {
          final topY = _platforms.map((p) => p['y']!).reduce(min) - 0.12;
          final np = {'x': _rand.nextDouble() * 0.6, 'y': topY, 'w': _rand.nextDouble() * 0.2 + 0.2};
          _platforms.add(np);
          _coins.add({'x': np['x']! + np['w']! / 2, 'y': np['y']! - 0.05});
        }
      }

      if (_playerY > 1.1) { _gameOver = true; _timer?.cancel(); }
    });
  }

  void _jump() { if (_onGround) setState(() { _vy = -0.03; _onGround = false; }); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Coin Collector', score: _score, isGameOver: _gameOver,
      onRestart: () => setState(_startGame), accentColor: const Color(0xFFFFD700),
      child: GestureDetector(
        onTap: _jump,
        onPanUpdate: (d) => setState(() => _playerX = (d.localPosition.dx / MediaQuery.of(context).size.width).clamp(0.05, 0.95)),
        child: Container(color: Colors.transparent, child: CustomPaint(
          painter: _CoinPainter(playerX: _playerX, playerY: _playerY, platforms: _platforms, coins: _coins),
          size: Size.infinite,
        )),
      ),
    );
  }
}

class _CoinPainter extends CustomPainter {
  final double playerX, playerY;
  final List<Map<String, double>> platforms, coins;
  _CoinPainter({required this.playerX, required this.playerY, required this.platforms, required this.coins});

  @override
  void paint(Canvas canvas, Size size) {
    // Platforms
    for (var p in platforms) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(p['x']! * size.width, p['y']! * size.height, p['w']! * size.width, 10), const Radius.circular(5)),
        Paint()..color = const Color(0xFF4CAF50));
    }
    // Coins
    for (var c in coins) {
      canvas.drawCircle(Offset(c['x']! * size.width, c['y']! * size.height), 10, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(c['x']! * size.width, c['y']! * size.height), 6, Paint()..color = const Color(0xFFFFA000));
    }
    // Player
    canvas.drawCircle(Offset(playerX * size.width, playerY * size.height), 14, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(playerX * size.width - 4, playerY * size.height - 4), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
