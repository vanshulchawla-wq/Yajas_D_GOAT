import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class GameScaffold extends StatelessWidget {
  final String title;
  final int score;
  final Widget child;
  final bool isGameOver;
  final VoidCallback? onRestart;
  final VoidCallback? onPause;
  final Color accentColor;

  const GameScaffold({
    super.key,
    required this.title,
    required this.score,
    required this.child,
    this.isGameOver = false,
    this.onRestart,
    this.onPause,
    this.accentColor = const Color(0xFFFF4500),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(child: Text(title, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor.withOpacity(0.5)),
                  ),
                  child: Text('$score pts', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: accentColor)),
                ),
                if (onPause != null)
                  IconButton(icon: const Icon(Icons.pause, color: Colors.white70), onPressed: onPause),
              ]),
            ),
            Expanded(child: child),
          ]),
          if (isGameOver)
            _GameOverOverlay(score: score, title: title, onRestart: onRestart, accentColor: accentColor),
        ]),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final String title;
  final VoidCallback? onRestart;
  final Color accentColor;
  const _GameOverOverlay({required this.score, required this.title, this.onRestart, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    ScoreManager.saveHighScore(title, score);
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 30)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('GAME OVER', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.w900, color: accentColor)),
            const SizedBox(height: 16),
            Text('Score', style: GoogleFonts.inter(fontSize: 14, color: Colors.white54)),
            Text('$score', style: GoogleFonts.orbitron(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: ScoreManager.getHighScore(title),
              builder: (_, snap) => Text('Best: ${snap.data ?? 0}', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
            ),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay, size: 18),
                label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Exit', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
