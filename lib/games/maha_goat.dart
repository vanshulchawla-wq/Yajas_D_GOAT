import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class MahaGoatGame extends StatefulWidget {
  const MahaGoatGame({super.key});
  @override
  State<MahaGoatGame> createState() => _MahaGoatGameState();
}

class _MahaGoatGameState extends State<MahaGoatGame> with TickerProviderStateMixin {
  // World
  static const _worldSize = 24;
  static const _viewRadius = 6;
  late List<List<List<int>>> _world; // 3D voxel grid [x][y][z] - 0=air,1=grass,2=dirt,3=stone,4=wood,5=leaves,6=water,7=sand,8=gold
  int _playerX = 12, _playerY = 12, _playerZ = 5;
  int _cameraAngle = 0; // 0,1,2,3 = N,E,S,W
  int _score = 0;
  int _health = 100;
  int _hunger = 100;
  bool _gameOver = false;
  Timer? _timer;
  final _rand = Random();

  // Inventory
  Map<int, int> _inventory = {}; // blockType -> count
  int _selectedBlock = 1;
  bool _buildMode = false;

  // Enemies
  List<Map<String, int>> _enemies = [];

  // Day/night cycle
  double _dayTime = 0.5; // 0-1
  bool _isNight = false;

  // Animation
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _generateWorld();
    _startGame();
  }

  void _generateWorld() {
    _world = List.generate(_worldSize, (x) => List.generate(_worldSize, (y) => List.generate(12, (z) => 0)));

    // Terrain generation with heightmap
    for (int x = 0; x < _worldSize; x++) {
      for (int y = 0; y < _worldSize; y++) {
        // Perlin-like noise using sin
        final height = (3 + (sin(x * 0.5) * cos(y * 0.4) * 2 + sin(x * 0.3 + y * 0.2) * 1.5)).toInt().clamp(2, 7);

        for (int z = 0; z < height; z++) {
          if (z == 0) _world[x][y][z] = 3; // bedrock/stone
          else if (z < height - 2) _world[x][y][z] = 3; // stone
          else if (z < height - 1) _world[x][y][z] = 2; // dirt
          else _world[x][y][z] = 1; // grass top
        }

        // Water in low areas
        if (height <= 3) {
          for (int z = height; z <= 3; z++) _world[x][y][z] = 6;
          if (height == 3) _world[x][y][height - 1] = 7; // sand near water
        }

        // Trees
        if (height > 3 && _rand.nextInt(15) == 0) {
          for (int tz = height; tz < height + 3; tz++) _world[x][y][tz] = 4; // trunk
          // Leaves
          for (int lx = -1; lx <= 1; lx++) {
            for (int ly = -1; ly <= 1; ly++) {
              for (int lz = height + 2; lz <= height + 4; lz++) {
                final nx = x + lx, ny = y + ly;
                if (nx >= 0 && nx < _worldSize && ny >= 0 && ny < _worldSize && lz < 12) {
                  if (_world[nx][ny][lz] == 0) _world[nx][ny][lz] = 5;
                }
              }
            }
          }
        }

        // Gold ore (rare)
        if (_rand.nextInt(50) == 0 && height > 2) {
          _world[x][y][1] = 8;
        }
      }
    }

    // Place player on surface
    _playerZ = _getHeight(_playerX, _playerY);
  }

  int _getHeight(int x, int y) {
    for (int z = 11; z >= 0; z--) {
      if (_world[x][y][z] != 0 && _world[x][y][z] != 6) return z + 1;
    }
    return 1;
  }

  void _startGame() {
    _score = 0; _health = 100; _hunger = 100; _gameOver = false;
    _inventory = {1: 10, 4: 5};
    _enemies = [];
    _dayTime = 0.5;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
    setState(() {});
  }

  void _tick(Timer t) {
    if (_gameOver) return;
    setState(() {
      // Day/night cycle
      _dayTime = (_dayTime + 0.0005) % 1.0;
      _isNight = _dayTime > 0.7 || _dayTime < 0.2;

      // Hunger decreases
      if (_rand.nextInt(30) == 0) {
        _hunger = max(0, _hunger - 1);
        if (_hunger <= 0) _health = max(0, _health - 1);
      }

      // Spawn enemies at night
      if (_isNight && _rand.nextInt(100) == 0 && _enemies.length < 5) {
        final ex = _rand.nextInt(_worldSize);
        final ey = _rand.nextInt(_worldSize);
        _enemies.add({'x': ex, 'y': ey, 'z': _getHeight(ex, ey), 'hp': 3});
      }

      // Move enemies toward player
      for (var e in _enemies) {
        if (_rand.nextInt(5) == 0) {
          final dx = (_playerX - e['x']!).sign;
          final dy = (_playerY - e['y']!).sign;
          final nx = (e['x']! + dx).clamp(0, _worldSize - 1);
          final ny = (e['y']! + dy).clamp(0, _worldSize - 1);
          e['x'] = nx; e['y'] = ny; e['z'] = _getHeight(nx, ny);
        }
        // Attack player
        if (e['x'] == _playerX && e['y'] == _playerY) {
          _health = max(0, _health - 5);
        }
      }

      if (_health <= 0) { _gameOver = true; _timer?.cancel(); }
    });
  }

  void _move(int dx, int dy) {
    if (_gameOver) return;
    // Rotate movement based on camera
    int rdx = dx, rdy = dy;
    for (int i = 0; i < _cameraAngle; i++) { final t = rdx; rdx = -rdy; rdy = t; }

    final nx = (_playerX + rdx).clamp(0, _worldSize - 1);
    final ny = (_playerY + rdy).clamp(0, _worldSize - 1);
    final nz = _getHeight(nx, ny);

    // Can climb 1 block
    if ((nz - _playerZ).abs() <= 1) {
      setState(() { _playerX = nx; _playerY = ny; _playerZ = nz; });
    }
  }

  void _mine() {
    if (_gameOver) return;
    // Mine block below player
    final z = _playerZ - 1;
    if (z >= 0 && _world[_playerX][_playerY][z] != 0) {
      final block = _world[_playerX][_playerY][z];
      setState(() {
        _world[_playerX][_playerY][z] = 0;
        _inventory[block] = (_inventory[block] ?? 0) + 1;
        _playerZ = _getHeight(_playerX, _playerY);
        _score += block == 8 ? 50 : 5;
      });
    }
  }

  void _placeBlock() {
    if (_gameOver || !_buildMode) return;
    if ((_inventory[_selectedBlock] ?? 0) > 0) {
      setState(() {
        _world[_playerX][_playerY][_playerZ] = _selectedBlock;
        _inventory[_selectedBlock] = _inventory[_selectedBlock]! - 1;
        _playerZ++;
        _score += 3;
      });
    }
  }

  void _attack() {
    _enemies.removeWhere((e) {
      if ((e['x']! - _playerX).abs() <= 1 && (e['y']! - _playerY).abs() <= 1) {
        e['hp'] = e['hp']! - 1;
        if (e['hp']! <= 0) { _score += 30; return true; }
      }
      return false;
    });
    setState(() {});
  }

  void _rotateCamera() => setState(() => _cameraAngle = (_cameraAngle + 1) % 4);

  @override
  void dispose() { _timer?.cancel(); _pulseController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'MahaGOAT', score: _score, isGameOver: _gameOver,
      onRestart: () { _generateWorld(); setState(_startGame); },
      accentColor: const Color(0xFF8B4513),
      child: Column(children: [
        // HUD
        _buildHUD(),
        // 3D World View
        Expanded(child: GestureDetector(
          onTap: _buildMode ? _placeBlock : _mine,
          onDoubleTap: _attack,
          child: CustomPaint(
            painter: _IsometricPainter(
              world: _world, playerX: _playerX, playerY: _playerY, playerZ: _playerZ,
              cameraAngle: _cameraAngle, viewRadius: _viewRadius, enemies: _enemies,
              isNight: _isNight, dayTime: _dayTime,
            ),
            size: Size.infinite,
          ),
        )),
        // Controls
        _buildControls(),
      ]),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Colors.black38,
      child: Row(children: [
        // Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset('assets/avatar.jpeg', width: 28, height: 28, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 28, height: 28, color: Colors.purple, child: const Center(child: Text('🥷', style: TextStyle(fontSize: 16))))),
        ),
        const SizedBox(width: 8),
        // Health
        _bar('❤️', _health, Colors.red),
        const SizedBox(width: 8),
        _bar('🍖', _hunger, Colors.orange),
        const Spacer(),
        // Day/night
        Text(_isNight ? '🌙' : '☀️', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        // Build mode toggle
        GestureDetector(
          onTap: () => setState(() => _buildMode = !_buildMode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _buildMode ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _buildMode ? Colors.green : Colors.white24),
            ),
            child: Text(_buildMode ? '🔨' : '⛏️', style: const TextStyle(fontSize: 14)),
          ),
        ),
      ]),
    );
  }

  Widget _bar(String icon, int val, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 12)),
    const SizedBox(width: 3),
    SizedBox(width: 50, height: 8, child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(value: val / 100, color: color, backgroundColor: Colors.white12),
    )),
  ]);

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black38,
      child: Column(children: [
        // Inventory bar
        SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
          ..._inventory.entries.where((e) => e.value > 0).map((e) => GestureDetector(
            onTap: () => setState(() => _selectedBlock = e.key),
            child: Container(
              width: 36, height: 36, margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _blockColor(e.key).withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _selectedBlock == e.key ? Colors.white : Colors.white24, width: _selectedBlock == e.key ? 2 : 1),
              ),
              child: Center(child: Text('${e.value}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
            ),
          )),
        ])),
        const SizedBox(height: 8),
        // D-pad + actions
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // D-pad
          SizedBox(width: 130, height: 100, child: Stack(children: [
            Positioned(top: 0, left: 40, child: _dBtn(Icons.arrow_upward, () => _move(0, -1))),
            Positioned(bottom: 0, left: 40, child: _dBtn(Icons.arrow_downward, () => _move(0, 1))),
            Positioned(top: 30, left: 0, child: _dBtn(Icons.arrow_back, () => _move(-1, 0))),
            Positioned(top: 30, right: 0, child: _dBtn(Icons.arrow_forward, () => _move(1, 0))),
          ])),
          // Action buttons
          Column(children: [
            Row(children: [
              _actionBtn('⛏️', _mine, 'Mine'),
              const SizedBox(width: 8),
              _actionBtn('⚔️', _attack, 'Attack'),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _actionBtn('🔄', _rotateCamera, 'Rotate'),
              const SizedBox(width: 8),
              _actionBtn('🔨', _placeBlock, 'Build'),
            ]),
          ]),
        ]),
      ]),
    );
  }

  Widget _dBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
      child: Icon(icon, color: Colors.white70, size: 20)),
  );

  Widget _actionBtn(String emoji, VoidCallback onTap, String label) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(label, style: GoogleFonts.inter(fontSize: 8, color: Colors.white38)),
      ]),
    ),
  );

  Color _blockColor(int type) {
    switch (type) {
      case 1: return const Color(0xFF4CAF50);
      case 2: return const Color(0xFF795548);
      case 3: return const Color(0xFF9E9E9E);
      case 4: return const Color(0xFF8D6E63);
      case 5: return const Color(0xFF2E7D32);
      case 6: return const Color(0xFF1565C0);
      case 7: return const Color(0xFFFFD54F);
      case 8: return const Color(0xFFFFD700);
      default: return Colors.white24;
    }
  }
}

class _IsometricPainter extends CustomPainter {
  final List<List<List<int>>> world;
  final int playerX, playerY, playerZ, cameraAngle, viewRadius;
  final List<Map<String, int>> enemies;
  final bool isNight;
  final double dayTime;

  _IsometricPainter({required this.world, required this.playerX, required this.playerY, required this.playerZ,
    required this.cameraAngle, required this.viewRadius, required this.enemies, required this.isNight, required this.dayTime});

  static const _tileW = 28.0;
  static const _tileH = 14.0;
  static const _tileZ = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;

    // Sky gradient based on time
    final skyTop = isNight ? const Color(0xFF0D0D2B) : const Color(0xFF87CEEB);
    final skyBot = isNight ? const Color(0xFF1A1A3E) : const Color(0xFFB3E5FC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [skyTop, skyBot]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Render visible blocks in isometric order
    final worldSize = world.length;
    final renderOrder = <_RenderBlock>[];

    for (int rx = -viewRadius; rx <= viewRadius; rx++) {
      for (int ry = -viewRadius; ry <= viewRadius; ry++) {
        int wx = playerX + rx, wy = playerY + ry;
        // Rotate based on camera
        for (int i = 0; i < cameraAngle; i++) { final t = rx; wx = playerX + ry; wy = playerY - rx; break; }
        wx = playerX + rx; wy = playerY + ry;
        // Apply camera rotation
        int vx = rx, vy = ry;
        for (int i = 0; i < cameraAngle; i++) { final t = vx; vx = vy; vy = -t; }

        if (wx < 0 || wx >= worldSize || wy < 0 || wy >= worldSize) continue;

        for (int z = 0; z < 12; z++) {
          final block = world[wx][wy][z];
          if (block == 0) continue;

          // Only render top-visible blocks (skip if block above)
          if (z < 11 && world[wx][wy][z + 1] != 0 && world[wx][wy][z + 1] != 6 && world[wx][wy][z + 1] != 5) continue;

          final isoX = cx + (vx - vy) * _tileW / 2;
          final isoY = cy + (vx + vy) * _tileH / 2 - z * _tileZ;
          renderOrder.add(_RenderBlock(isoX, isoY, block, vx + vy + z * 100));
        }
      }
    }

    // Sort by depth
    renderOrder.sort((a, b) => a.depth.compareTo(b.depth));

    // Draw blocks
    for (final rb in renderOrder) {
      _drawBlock(canvas, rb.x, rb.y, rb.type);
    }

    // Draw enemies
    for (final e in enemies) {
      final ex = e['x']! - playerX, ey = e['y']! - playerY;
      if (ex.abs() > viewRadius || ey.abs() > viewRadius) continue;
      int vx = ex, vy = ey;
      for (int i = 0; i < cameraAngle; i++) { final t = vx; vx = vy; vy = -t; }
      final isoX = cx + (vx - vy) * _tileW / 2;
      final isoY = cy + (vx + vy) * _tileH / 2 - e['z']! * _tileZ;
      // Zombie
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(isoX, isoY - 12), width: 12, height: 18), const Radius.circular(3)),
        Paint()..color = const Color(0xFF4A148C));
      canvas.drawCircle(Offset(isoX, isoY - 22), 6, Paint()..color = const Color(0xFF6A1B9A));
      // Eyes
      canvas.drawCircle(Offset(isoX - 2, isoY - 23), 2, Paint()..color = Colors.red);
      canvas.drawCircle(Offset(isoX + 2, isoY - 23), 2, Paint()..color = Colors.red);
    }

    // Draw player (avatar representation)
    final pIsoX = cx;
    final pIsoY = cy - playerZ * _tileZ;
    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(pIsoX, pIsoY - 14), width: 14, height: 22), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1A237E));
    // Head
    canvas.drawCircle(Offset(pIsoX, pIsoY - 28), 8, Paint()..color = const Color(0xFF8D6E63));
    // Crown (GOAT indicator)
    canvas.drawPath(Path()..moveTo(pIsoX - 6, pIsoY - 36)..lineTo(pIsoX - 4, pIsoY - 40)..lineTo(pIsoX, pIsoY - 37)
      ..lineTo(pIsoX + 4, pIsoY - 40)..lineTo(pIsoX + 6, pIsoY - 36)..close(), Paint()..color = const Color(0xFFFFD700));
    // Shadow
    canvas.drawOval(Rect.fromCenter(center: Offset(pIsoX, pIsoY + 2), width: 16, height: 6), Paint()..color = Colors.black26);

    // Night overlay
    if (isNight) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.3));
      // Torch glow around player
      canvas.drawCircle(Offset(pIsoX, pIsoY - 10), 60, Paint()..color = Colors.orange.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    }
  }

  void _drawBlock(Canvas canvas, double x, double y, int type) {
    final color = _getColor(type);
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    final light = Color.lerp(color, Colors.white, 0.15)!;

    // Top face
    final top = Path()..moveTo(x, y - _tileH)..lineTo(x + _tileW / 2, y)..lineTo(x, y + _tileH)..lineTo(x - _tileW / 2, y)..close();
    canvas.drawPath(top, Paint()..color = light);

    // Left face
    final left = Path()..moveTo(x - _tileW / 2, y)..lineTo(x, y + _tileH)..lineTo(x, y + _tileH + _tileZ)..lineTo(x - _tileW / 2, y + _tileZ)..close();
    canvas.drawPath(left, Paint()..color = dark);

    // Right face
    final right = Path()..moveTo(x + _tileW / 2, y)..lineTo(x, y + _tileH)..lineTo(x, y + _tileH + _tileZ)..lineTo(x + _tileW / 2, y + _tileZ)..close();
    canvas.drawPath(right, Paint()..color = color);

    // Water shimmer
    if (type == 6) {
      canvas.drawPath(top, Paint()..color = Colors.white.withOpacity(0.1));
    }
    // Gold sparkle
    if (type == 8) {
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white.withOpacity(0.6));
    }
  }

  Color _getColor(int type) {
    switch (type) {
      case 1: return const Color(0xFF4CAF50); // grass
      case 2: return const Color(0xFF6D4C41); // dirt
      case 3: return const Color(0xFF757575); // stone
      case 4: return const Color(0xFF8D6E63); // wood
      case 5: return const Color(0xFF2E7D32); // leaves
      case 6: return const Color(0xFF1565C0); // water
      case 7: return const Color(0xFFFFD54F); // sand
      case 8: return const Color(0xFFFFD700); // gold
      default: return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RenderBlock {
  final double x, y;
  final int type, depth;
  _RenderBlock(this.x, this.y, this.type, this.depth);
}
