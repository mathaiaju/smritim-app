import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smritim_app/screens/patient/patient_landing_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';
import 'dashboard_screen.dart';
import '../widgets/app_header.dart';
import '../screens/clinician/clinician_dashboard_screen.dart';
import '../utils/biometric_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool biometricAvailable = false;
  bool obscurePassword = true;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    username.addListener(() => setState(() {}));
    password.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final supported = await BiometricAuth.isSupported();
    final canAuth = await BiometricAuth.canAuthenticate();
    final prefs = await SharedPreferences.getInstance();
    final lastUserId = prefs.getString('last_user_id');
    if (lastUserId != null) {
      final storedUser = await _secureStorage.read(key: 'bio_user_$lastUserId');
      // Always show biometric if credentials exist for last user
      setState(() => biometricAvailable = supported && canAuth && storedUser != null);
    } else {
      setState(() => biometricAvailable = false);
    }
  }

  Future<void> _biometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUserId = prefs.getString('last_user_id');
    
    if (lastUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved biometric login found')),
      );
      return;
    }

    final ok = await BiometricAuth.authenticate();
    if (!ok) return;

    final storedUser = await _secureStorage.read(key: 'bio_user_$lastUserId');
    final storedPass = await _secureStorage.read(key: 'bio_pass_$lastUserId');
    
    if (storedUser == null || storedPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved credentials found')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiClient.postJson(
        '/auth/login',
        {'username': storedUser, 'password': storedPass},
      );

      setState(() => loading = false);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await ApiClient.setSession(
          token: data['token'],
          user: {
            'id': data['id'],
            'username': storedUser,
            'role': data['role'],
            'hospital_id': data['hospital_id'],
          },
        );

        _navigateByRole(data['role']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric login failed')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    }
  }

  Future<void> login() async {
    try {
      setState(() => loading = true);

      final res = await ApiClient.postJson(
        '/auth/login',
        {
          'username': username.text.trim(),
          'password': password.text.trim(),
        },
      );

      setState(() => loading = false);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final role = data['role'];
        final userId = data['id']?.toString() ?? username.text.trim();
        await ApiClient.setSession(
          token: data['token'],
          user: {
            'id': data['id'],
            'username': username.text.trim(),
            'role': data['role'],
            'hospital_id': data['hospital_id'],
          },
        );
        // Store credentials securely if biometric is enabled
        if (ApiClient.biometricEnabled) {
          print('📝 Storing credentials for userId: $userId');
          await _secureStorage.write(key: 'bio_user_$userId', value: username.text.trim());
          await _secureStorage.write(key: 'bio_pass_$userId', value: password.text.trim());
        }
        // Always set last_user_id
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_id', userId);
        // Store password for biometric toggle
        ApiClient.setCurrentPassword(password.text.trim());
        _navigateByRole(role);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonDecode(res.body)['error'] ?? 'Login failed',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }

  void _navigateByRole(String role) {
    Widget target;
    if (role == 'hospital_admin') {
      target = const DashboardScreen();
    } else if (role == 'clinician') {
      target = const ClinicianDashboardScreen();
    } else {
      target = const PatientLandingScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  bool get canLogin => username.text.trim().isNotEmpty && password.text.isNotEmpty && !loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF1F5FF), Color(0xFFE0E7FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: SvgPicture.asset(
                        'assets/logo/smriti-m.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Text(
                    'SMRITI-M',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hospital Administration Portal',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Glassmorphism card
                  Card(
                    elevation: 12,
                    color: Colors.white.withOpacity(0.85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username
                          TextField(
                            controller: username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password with show/hide
                          TextField(
                            controller: password,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => obscurePassword = !obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: canLogin ? const Color(0xFF1E3A8A) : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: canLogin ? login : null,
                                child: loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Login', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                          // Biometric Login
                          if (biometricAvailable) ...[
                            const SizedBox(height: 18),
                            const Text('OR', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            AnimatedScale(
                              scale: biometricAvailable ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 350),
                              child: IconButton(
                                onPressed: loading ? null : _biometricLogin,
                                icon: const Icon(Icons.fingerprint, size: 48),
                                color: const Color(0xFF1E3A8A),
                                tooltip: 'Login with Biometric',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Footer
                  Text(
                    '© 2026 SmritiM Health. All rights reserved.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
