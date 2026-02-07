import 'dart:async';
import 'package:flutter/material.dart';
import '../api_client.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../screens/clinician/clinician_dashboard_screen.dart';
import '../screens/patient/patient_landing_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // ⏳ Hold splash for 3 seconds
    Timer(const Duration(seconds: 5), _navigate);
  }

  Future<void> _navigate() async {
    Widget target = ApiClient.isLoggedIn ? _routeByRole() : const LoginScreen();

    if (!mounted) return;

    await _fadeController.forward();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: target),
      ),
    );
  }

  Widget _routeByRole() {
    final role = ApiClient.currentUser?['role'];
    if (role == 'hospital_admin') return const DashboardScreen();
    if (role == 'clinician') return const ClinicianDashboardScreen();
    return const PatientLandingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FF),
      body: Stack(
        children: [
          // Animated gradient background
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFF1F5FF), const Color(0xFFDBEAFE), value)!,
                      Color.lerp(const Color(0xFFE0E7FF), const Color(0xFF1E3A8A), value * 0.7)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.0).animate(_fadeController),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: SvgPicture.asset(
                        'assets/logo/smriti-m.svg',
                        width: 120,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Animated app name
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: child,
                      ),
                      child: const Text(
                        'SMRITI-M',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Staggered acronym block
                    _AnimatedAcronymBlock(),
                    const SizedBox(height: 36),
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1E3A8A),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}

/// Animated version of the acronym block
class _AnimatedAcronymBlock extends StatelessWidget {
  const _AnimatedAcronymBlock();
  @override
  Widget build(BuildContext context) {
    final lines = const [
      _AcronymLine(letter: 'S', text: 'Scalable'),
      _AcronymLine(letter: 'M', text: 'Modular'),
      _AcronymLine(letter: 'R', text: 'Responsive'),
      _AcronymLine(letter: 'I', text: 'Integrated'),
      _AcronymLine(letter: 'T', text: 'Technology'),
      _AcronymLine(letter: 'I', text: 'for Improving'),
      _AcronymLine(letter: 'M', text: 'Medication Safety & Adherence', highlight: true),
    ];
    return Column(
      children: List.generate(lines.length, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + i * 120),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Padding(
              padding: EdgeInsets.only(left: value * 8),
              child: child,
            ),
          ),
          child: lines[i],
        );
      }),
    );
  }
}

/// =====================================================
/// 🧩 ACRONYM BLOCK (UNIQUE STYLE)
/// =====================================================
class _AcronymBlock extends StatelessWidget {
  const _AcronymBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AcronymLine(letter: 'S', text: 'Scalable'),
        _AcronymLine(letter: 'M', text: 'Modular'),
        _AcronymLine(letter: 'R', text: 'Responsive'),
        _AcronymLine(letter: 'I', text: 'Integrated'),
        _AcronymLine(letter: 'T', text: 'Technology'),
        _AcronymLine(letter: 'I', text: 'for Improving'),
        _AcronymLine(
          letter: 'M',
          text: 'Medication Safety & Adherence',
          highlight: true,
        ),
      ],
    );
  }
}

class _AcronymLine extends StatelessWidget {
  final String letter;
  final String text;
  final bool highlight;

  const _AcronymLine({
    required this.letter,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              color: highlight ? const Color(0xFF1E3A8A) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
