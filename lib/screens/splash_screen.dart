import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _secureStorage = const FlutterSecureStorage();

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

    print('🔐 Biometric check:');
    print('  - isLoggedIn: ${ApiClient.isLoggedIn}');
    print('  - biometricEnabled: ${ApiClient.biometricEnabled}');
    print('  - currentUser: ${ApiClient.currentUser}');

    if (ApiClient.isLoggedIn) {
      print('  - Taking isLoggedIn branch');
      final isSupported = await BiometricAuth.isSupported();
      final canAuth = await BiometricAuth.canAuthenticate();
      
      print('  - isSupported: $isSupported');
      print('  - canAuthenticate: $canAuth');

      if (ApiClient.biometricEnabled && isSupported && canAuth) {
        print('  - Showing biometric prompt...');
        final ok = await BiometricAuth.authenticate();
        print('  - Biometric result: $ok');
        target = ok ? _routeByRole() : const LoginScreen();
      } else {
        print('  - Skipping biometric (not enabled or not available)');
        target = _routeByRole();
      }
    } else if (ApiClient.biometricEnabled) {
      // No session but biometric enabled - try auto-login
      final isSupported = await BiometricAuth.isSupported();
      final canAuth = await BiometricAuth.canAuthenticate();
      
      if (isSupported && canAuth) {
        print('  - Attempting biometric auto-login...');
        final ok = await BiometricAuth.authenticate();
        
        if (ok) {
          // Get last user ID from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final lastUserId = prefs.getString('last_user_id');
          print('  - Last user ID: $lastUserId');
          
          if (lastUserId != null) {
            final storedUser = await _secureStorage.read(key: 'bio_user_$lastUserId');
            final storedPass = await _secureStorage.read(key: 'bio_pass_$lastUserId');
            print('  - Stored user: $storedUser');
            print('  - Stored pass: ${storedPass != null ? "***" : "null"}');
            
            if (storedUser != null && storedPass != null) {
              try {
                print('  - Attempting login...');
                final res = await ApiClient.postJson(
                  '/auth/login',
                  {'username': storedUser, 'password': storedPass},
                );
                
                print('  - Login response: ${res.statusCode}');
                if (res.statusCode == 200) {
                  final data = jsonDecode(res.body);
                  await ApiClient.setSession(
                    token: data['token'],
                    user: {
                      'username': storedUser,
                      'role': data['role'],
                      'hospital_id': data['hospital_id'],
                      'id': data['id'],
                    },
                  );
                  print('  - Auto-login successful!');
                  target = _routeByRole();
                } else {
                  print('  - Login failed: ${res.body}');
                }
              } catch (e) {
                print('  - Auto-login failed: $e');
              }
            } else {
              print('  - No stored credentials found');
            }
          } else {
            print('  - No last_user_id found');
          }
        }
      }
    } else {
      print('  - Not logged in, showing login screen');
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
