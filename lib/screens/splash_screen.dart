import 'dart:async';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../utils/biometric_auth.dart';
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
    Widget target = const LoginScreen();

    if (ApiClient.isLoggedIn) {
      if (ApiClient.biometricEnabled &&
          await BiometricAuth.isSupported() &&
          await BiometricAuth.canAuthenticate()) {
        final ok = await BiometricAuth.authenticate();
        target = ok ? _routeByRole() : const LoginScreen();
      } else {
        target = _routeByRole();
      }
    }

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
      backgroundColor: const Color(0xFFF1F5FF), // soft clinical blue
      body: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(_fadeController),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO
                SvgPicture.asset(
                  'assets/logo/smriti-m.svg',
                  width: 120,
                ),

                const SizedBox(height: 24),

                /// APP NAME
                const Text(
                  'SMRITI-M',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: Color(0xFF1E3A8A),
                  ),
                ),

                const SizedBox(height: 18),

                /// ACRONYM EXPANSION
                const _AcronymBlock(),

                const SizedBox(height: 36),

                /// LOADING
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1E3A8A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
