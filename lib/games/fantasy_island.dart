import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class FantasyIslandGame extends StatefulWidget {
  const FantasyIslandGame({super.key});
  @override
  State<FantasyIslandGame> createState() => _FantasyIslandGameState();
}

class _FantasyIslandGameState extends State<FantasyIslandGame> {
  int _score = 0;
  int _gold = 50;
  int _wood = 30;
  int _stone = 20;
  int _food = 40;
  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _floatingItems = [];
  Timer? _timer;
  final _rand = Random();
  bool _gameOver = false;
  int _turn = 0;
  int _population = 5;

  final List<Map<String, dynamic>> _buildOptions = [
    {'name': 'House', 'icon': '🏠', 'gold': 20, 'wood': 15, 'pop': 3, 'pts': 20},
    {'name': 'Farm', 'icon': '🌾', 'gold': 15, 'wood': 10, 'food': 5, 'pts': 15},
    {'name': 'Mine', 'icon': '⛏️', 'gold': 10, 'stone': 5, 'pts': 25},
    {'name': 'Tower', 'icon': '🗼', 'gold': 40, 'stone': 30, 'pts': 50},
    {'name': 'Market', 'icon': '🏪', 'gold': 30, 'wood': 20, 'pts': 35},
    {'name': 'Temple', 'icon': '⛩️', 'gold': 60, 'stone': 40, 'pts': 80},
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _gold = 50;
    _wood = 30;
    _stone = 20;
    _food = 40;
    _buildings = [];
    _floatingItems = [];
    _gameOver = false;
    _turn = 0;
    _population = 5;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), _spawnResource);
  }

  void _spawnResource(Timer t) {
    if (_gameOver) return;
    setState(() {
      _turn++;
      _food -= _population ~/ 2;
      if (_food <= 0) {
        _gameOver = true;
        _timer?.cancel();
        return;
      }
      // Spawn floating collectibles
      if (_floatingItems.length < 5) {
        final types = ['🪙', '🪵', '🪨', '🍎'];
        _floatingItems.add({
          'type': types[_rand.nextInt(types.length)],
          'x': _rand.nextDouble() * 0.8 + 0.1,
          'y': _rand.nextDouble() * 0.3 + 0.15,
          'life': 8,
        });
      }
      // Decay items
      _floatingItems = _floatingItems.map((i) {
        i['life'] = (i['life'] as int) - 1;
        return i;
      }).where((i) => (i['life'] as int) > 0).toList();
    });
  }

  void _collectItem(int index) {
    final item = _floatingItems[index];
    setState(() {
      switch (item['type']) {
        case '🪙': _gold += 10; break;
        case '🪵': _wood += 8; break;
        case '🪨': _stone += 6; break;
        case '🍎': _food += 12; break;
      }
      _score += 5;
      _floatingItems.removeAt(index);
    });
  }

  void _build(Map<String, dynamic> option) {
    final cost = option['gold'] as int;
    final woodCost = (option['wood'] as int?) ?? 0;
    final stoneCost = (option['stone'] as int?) ?? 0;
    if (_gold >= cost && _wood >= woodCost && _stone >= stoneCost) {
      setState(() {
        _gold -= cost;
        _wood -= woodCost;
        _stone -= stoneCost;
        _buildings.add(option);
        _score += option['pts'] as int;
        if (option['pop'] != null) _population += option['pop'] as int;
        if (option['food'] != null) _food += option['food'] as int;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Fantasy Island',
      score: _score,
      isGameOver: _gameOver,
      onRestart: () => setState(_startGame),
      accentColor: const Color(0xFF6200EA),
      child: Column(children: [
        // Resources bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _res('🪙', _gold),
            _res('🪵', _wood),
            _res('🪨', _stone),
            _res('🍎', _food),
            _res('👥', _population),
          ]),
        ),
        // Island view with collectibles
        Expanded(
          flex: 3,
          child: Stack(children: [
            // Island background
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF87CEEB), Color(0xFF228B22), Color(0xFF1B5E20)]),
              ),
              child: Center(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _buildings.map((b) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Text(b['icon'], style: const TextStyle(fontSize: 28)),
                  )).toList(),
                ),
              ),
            ),
            // Floating collectibles
            ..._floatingItems.asMap().entries.map((e) => Positioned(
              left: e.value['x'] * MediaQuery.of(context).size.width * 0.7,
              top: e.value['y'] * 200,
              child: GestureDetector(
                onTap: () => _collectItem(e.key),
                child: AnimatedOpacity(
                  opacity: (e.value['life'] as int) > 2 ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Text(e.value['type'], style: const TextStyle(fontSize: 30)),
                ),
              ),
            )),
          ]),
        ),
        // Build options
        Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _buildOptions.length,
            itemBuilder: (_, i) {
              final opt = _buildOptions[i];
              final canBuild = _gold >= (opt['gold'] as int) && _wood >= ((opt['wood'] as int?) ?? 0) && _stone >= ((opt['stone'] as int?) ?? 0);
              return GestureDetector(
                onTap: canBuild ? () => _build(opt) : null,
                child: Container(
                  width: 80, margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: canBuild ? const Color(0xFF6200EA).withOpacity(0.3) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: canBuild ? const Color(0xFF6200EA) : Colors.white12),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(opt['icon'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(opt['name'], style: GoogleFonts.inter(fontSize: 9, color: Colors.white70)),
                    Text('${opt['gold']}🪙', style: GoogleFonts.inter(fontSize: 9, color: Colors.amber)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _res(String icon, int val) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 2),
    Text('$val', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
  ]);
}
