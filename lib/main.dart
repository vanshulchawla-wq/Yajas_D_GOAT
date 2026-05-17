import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const HomeScreen();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1565C0), Color(0xFF0D47A1)])),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(24),
            child: Image.asset('assets/avatar.jpeg', width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 80, color: Colors.white))),
          const SizedBox(height: 24),
          Text('YCExamPrep', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text('CBSE Board Exam Preparation', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        ])),
      ),
    );
  }
}
