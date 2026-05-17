import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const YCExamApp());
}

class YCExamApp extends StatelessWidget {
  const YCExamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YCExamPrep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1565C0),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1565C0), foregroundColor: Colors.white, elevation: 0),
      ),
      home: const SplashWrapper(),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});
  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final tts = FlutterTts();
    await tts.setPitch(0.6);
    await tts.setSpeechRate(0.38);
    await tts.setVolume(1.0);
    await tts.speak('Board Exam Preparation App');
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const HomeScreen();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1565C0), Color(0xFF0D47A1)])),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/avatar.jpeg', width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 80, color: Colors.white))),
          const SizedBox(height: 20),
          Text('YCExamPrep', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text('CBSE Board Exam Preparation', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 30),
          const CircularProgressIndicator(color: Colors.white),
        ])),
      ),
    );
  }
}
