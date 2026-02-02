import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smritim_app/screens/patient/patient_landing_screen.dart';
import '../api_client.dart';
import 'dashboard_screen.dart';
import '../widgets/app_header.dart';
import '../screens/clinician/clinician_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

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
        ApiClient.enableBiometric(true);
        final data = jsonDecode(res.body);
        final role = data['role'];
        ApiClient.setSession(
          token: data['token'],
          user: {
            'username':
                username.text.trim(), // CORRECT – store the actual string
            'role': data['role'],
            'hospital_id': data['hospital_id'],
          },
        );

        // ✅ ROLE-BASED ROUTING
        Widget target;

        if (role == 'hospital_admin') {
          target = const DashboardScreen();
        } else if (role == 'clinician') {
          target = const ClinicianDashboardScreen();
        } else {
          target = const PatientLandingScreen();

          //throw Exception('Unsupported role: $role');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => target),
        );

        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );*/
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ✅ LOGO + TITLE
                  const AppHeader(
                    subtitle: 'Hospital Administration Portal',
                  ),

                  /// Username
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Password
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
