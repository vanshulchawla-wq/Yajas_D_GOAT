import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../main.dart';
import '../games/jet_shooter.dart';
import '../games/table_tennis.dart';
import '../games/fantasy_island.dart';
import '../games/snake_game.dart';
import '../games/flappy_bird.dart';
import '../games/brick_breaker.dart';
import '../games/space_invaders.dart';
import '../games/dino_run.dart';
import '../games/color_match.dart';
import '../games/memory_cards.dart';
import '../games/whack_a_mole.dart';
import '../games/fruit_ninja.dart';
import '../games/racing_game.dart';
import '../games/bubble_shooter.dart';
import '../games/tetris_game.dart';
import '../games/maze_runner.dart';
import '../games/asteroid_dodge.dart';
import '../games/word_scramble.dart';
import '../games/reaction_time.dart';
import '../games/tower_stack.dart';
import '../games/coin_collector.dart';
import '../games/math_blitz.dart';
import '../games/tap_tap.dart';
import '../games/gravity_ball.dart';
import '../games/ninja_jump.dart';
import '../games/maha_goat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalPoints = 0;
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _games = [
    {'name': 'MahaGOAT', 'icon': '🐐', 'color': 0xFF8B4513, 'category': 'Adventure', 'builder': (ctx) => const MahaGoatGame()},
    {'name': 'Jet Shooter', 'icon': '✈️', 'color': 0xFFFF4500, 'category': 'Action', 'builder': (ctx) => const JetShooterGame()},
    {'name': 'Table Tennis', 'icon': '🏓', 'color': 0xFF00C853, 'category': 'Sports', 'builder': (ctx) => const TableTennisGame()},
    {'name': 'Fantasy Island', 'icon': '🏝️', 'color': 0xFF6200EA, 'category': 'Adventure', 'builder': (ctx) => const FantasyIslandGame()},
    {'name': 'Snake', 'icon': '🐍', 'color': 0xFF4CAF50, 'category': 'Classic', 'builder': (ctx) => const SnakeGame()},
    {'name': 'Flappy Bird', 'icon': '🐦', 'color': 0xFFFFEB3B, 'category': 'Classic', 'builder': (ctx) => const FlappyBirdGame()},
    {'name': 'Brick Breaker', 'icon': '🧱', 'color': 0xFFE91E63, 'category': 'Classic', 'builder': (ctx) => const BrickBreakerGame()},
    {'name': 'Space Invaders', 'icon': '👾', 'color': 0xFF9C27B0, 'category': 'Action', 'builder': (ctx) => const SpaceInvadersGame()},
    {'name': 'Dino Run', 'icon': '🦖', 'color': 0xFF795548, 'category': 'Runner', 'builder': (ctx) => const DinoRunGame()},
    {'name': 'Color Match', 'icon': '🎨', 'color': 0xFFFF9800, 'category': 'Puzzle', 'builder': (ctx) => const ColorMatchGame()},
    {'name': 'Memory Cards', 'icon': '🃏', 'color': 0xFF607D8B, 'category': 'Puzzle', 'builder': (ctx) => const MemoryCardsGame()},
    {'name': 'Whack-a-Mole', 'icon': '🔨', 'color': 0xFF8D6E63, 'category': 'Arcade', 'builder': (ctx) => const WhackAMoleGame()},
    {'name': 'Fruit Ninja', 'icon': '🍉', 'color': 0xFFF44336, 'category': 'Arcade', 'builder': (ctx) => const FruitNinjaGame()},
    {'name': 'Racing', 'icon': '🏎️', 'color': 0xFF2196F3, 'category': 'Sports', 'builder': (ctx) => const RacingGame()},
    {'name': 'Bubble Pop', 'icon': '🫧', 'color': 0xFF00BCD4, 'category': 'Puzzle', 'builder': (ctx) => const BubbleShooterGame()},
    {'name': 'Tetris', 'icon': '🟦', 'color': 0xFF3F51B5, 'category': 'Classic', 'builder': (ctx) => const TetrisGame()},
    {'name': 'Maze Runner', 'icon': '🌀', 'color': 0xFF009688, 'category': 'Puzzle', 'builder': (ctx) => const MazeRunnerGame()},
    {'name': 'Asteroid Dodge', 'icon': '☄️', 'color': 0xFFFF5722, 'category': 'Action', 'builder': (ctx) => const AsteroidDodgeGame()},
    {'name': 'Word Scramble', 'icon': '📝', 'color': 0xFF673AB7, 'category': 'Brain', 'builder': (ctx) => const WordScrambleGame()},
    {'name': 'Reaction Time', 'icon': '⚡', 'color': 0xFFFFC107, 'category': 'Brain', 'builder': (ctx) => const ReactionTimeGame()},
    {'name': 'Tower Stack', 'icon': '🏗️', 'color': 0xFF455A64, 'category': 'Arcade', 'builder': (ctx) => const TowerStackGame()},
    {'name': 'Coin Collector', 'icon': '🪙', 'color': 0xFFFFD700, 'category': 'Runner', 'builder': (ctx) => const CoinCollectorGame()},
    {'name': 'Math Blitz', 'icon': '🧮', 'color': 0xFF1DE9B6, 'category': 'Brain', 'builder': (ctx) => const MathBlitzGame()},
    {'name': 'Tap Tap', 'icon': '👆', 'color': 0xFFE040FB, 'category': 'Arcade', 'builder': (ctx) => const TapTapGame()},
    {'name': 'Gravity Ball', 'icon': '🔮', 'color': 0xFF304FFE, 'category': 'Action', 'builder': (ctx) => const GravityBallGame()},
    {'name': 'Ninja Jump', 'icon': '🥷', 'color': 0xFF212121, 'category': 'Runner', 'builder': (ctx) => const NinjaJumpGame()},
  ];

  final List<String> _categories = ['All', 'Action', 'Classic', 'Puzzle', 'Arcade', 'Sports', 'Runner', 'Brain', 'Adventure'];

  @override
  void initState() {
    super.initState();
    _loadPoints();
    _playIntro();
  }

  Future<void> _playIntro() async {
    final tts = FlutterTts();
    await tts.setPitch(1.8);
    await tts.setSpeechRate(0.45);
    await tts.setVolume(1.0);
    await tts.speak('YC Gaming. The GOAT Culture.');
  }

  Future<void> _loadPoints() async {
    final pts = await ScoreManager.getTotalPoints();
    if (mounted) setState(() => _totalPoints = pts);
  }

  List<Map<String, dynamic>> get _filteredGames {
    if (_selectedCategory == 'All') return _games;
    return _games.where((g) => g['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [Color(0xFFFF4500), Color(0xFFFF8C00)]),
                ),
                child: const Center(child: Text('🎮', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('YCGaming', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('${_games.length} Games', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4500).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF4500).withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🏆', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('$_totalPoints', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFF4500))),
                ]),
              ),
            ]),
          ),
          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFFF4500) : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? Colors.transparent : Colors.white12),
                      ),
                      child: Text(cat, style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.white54,
                      )),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Games Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1,
              ),
              itemCount: _filteredGames.length,
              itemBuilder: (_, i) => _GameCard(
                game: _filteredGames[i],
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: _filteredGames[i]['builder']));
                  _loadPoints();
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final VoidCallback onTap;
  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(game['color']).withOpacity(0.3), Color(game['color']).withOpacity(0.1)],
          ),
          border: Border.all(color: Color(game['color']).withOpacity(0.4)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(game['icon'], style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(game['name'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(game['color']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(game['category'], style: GoogleFonts.inter(fontSize: 9, color: Colors.white54)),
          ),
        ]),
      ),
    );
  }
}
