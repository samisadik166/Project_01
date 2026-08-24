import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized: ${Firebase.app().options.projectId}');
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
  runApp(const PreschoolApp());
}

class PreschoolApp extends StatelessWidget {
  const PreschoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Little Learners',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ComicNeue', // add a rounded/playful font in pubspec.yaml
        scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// SPLASH SCREEN
// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to login page after splash delay
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, __) => const LoginPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D), // pink
              Color(0xFFFFC93C), // yellow
              Color(0xFF4EE0C1), // teal
            ],
          ),
        ),
        child: Stack(
          children: [
            // decorative floating shapes
            const _FloatingShape(
              top: 60,
              left: 30,
              icon: Icons.star,
              color: Colors.white,
              size: 40,
            ),
            const _FloatingShape(
              top: 120,
              right: 40,
              icon: Icons.favorite,
              color: Colors.white,
              size: 30,
            ),
            const _FloatingShape(
              bottom: 150,
              left: 50,
              icon: Icons.circle,
              color: Colors.white,
              size: 25,
            ),
            const _FloatingShape(
              bottom: 100,
              right: 30,
              icon: Icons.change_history,
              color: Colors.white,
              size: 35,
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_emotions_rounded,
                        size: 100,
                        color: Color(0xFFFF6B9D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: const [
                        Text(
                          'Little Learners',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Learning is fun! 🌈',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// small helper widget for floating decorative shapes on splash screen
class _FloatingShape extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final IconData icon;
  final Color color;
  final double size;

  const _FloatingShape({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(icon, color: color.withOpacity(0.5), size: size),
    );
  }
}
