import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const YCGamingApp());
}

class YCGamingApp extends StatelessWidget {
  const YCGamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YCGaming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        primaryColor: const Color(0xFFFF4500),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4500),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1A1A2E),
        ),
        textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}

class ScoreManager {
  static Future<int> getHighScore(String game) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('hs_$game') ?? 0;
  }

  static Future<void> saveHighScore(String game, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('hs_$game') ?? 0;
    if (score > current) await prefs.setInt('hs_$game', score);
  }

  static Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith('hs_')) total += prefs.getInt(key) ?? 0;
    }
    return total;
  }
}
