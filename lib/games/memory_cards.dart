import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';

class MemoryCardsGame extends StatefulWidget {
  const MemoryCardsGame({super.key});
  @override
  State<MemoryCardsGame> createState() => _MemoryCardsGameState();
}

class _MemoryCardsGameState extends State<MemoryCardsGame> {
  final _emojis = ['🎮', '🚀', '⚡', '🔥', '💎', '🎯', '🌟', '🎪'];
  List<String> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  int? _firstIndex;
  int _score = 0;
  int _moves = 0;
  bool _gameOver = false;
  bool _locked = false;

  @override
  void initState() { super.initState(); _startGame(); }

  void _startGame() {
    _cards = [..._emojis, ..._emojis]..shuffle();
    _revealed = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstIndex = null; _score = 0; _moves = 0; _gameOver = false; _locked = false;
    setState(() {});
  }

  void _tap(int index) {
    if (_locked || _revealed[index] || _matched[index]) return;
    setState(() {
      _revealed[index] = true;
      if (_firstIndex == null) {
        _firstIndex = index;
      } else {
        _moves++;
        if (_cards[_firstIndex!] == _cards[index]) {
          _matched[_firstIndex!] = true; _matched[index] = true;
          _score += 20;
          _firstIndex = null;
          if (_matched.every((m) => m)) { _gameOver = true; _score += max(0, 100 - _moves * 3); }
        } else {
          _locked = true;
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() { _revealed[_firstIndex!] = false; _revealed[index] = false; _firstIndex = null; _locked = false; });
          });
        }
      }
    });
  }

  int max(int a, int b) => a > b ? a : b;

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Memory Cards', score: _score, isGameOver: _gameOver,
      onRestart: _startGame, accentColor: const Color(0xFF607D8B),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(12),
          child: Text('Moves: $_moves', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14))),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: 16,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _tap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _matched[i] ? Colors.green.withOpacity(0.3) : _revealed[i] ? const Color(0xFF1A1A2E) : const Color(0xFF607D8B).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _matched[i] ? Colors.green : _revealed[i] ? Colors.white24 : const Color(0xFF607D8B)),
              ),
              child: Center(child: Text(
                _revealed[i] || _matched[i] ? _cards[i] : '?',
                style: TextStyle(fontSize: _revealed[i] || _matched[i] ? 28 : 22, color: Colors.white54),
              )),
            ),
          ),
        )),
      ]),
    );
  }
}
