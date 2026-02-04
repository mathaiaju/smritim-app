import 'package:flutter/material.dart';
import '../api_client.dart';

import '../screens/login_screen.dart';
import '../screens/patient/patient_landing_screen.dart';
import '../screens/patient/patient_chatbot_screen.dart';
import '../screens/alerts_screen.dart';
import '../main.dart';
import '../utils/biometric_auth.dart';

import 'package:flutter_svg/flutter_svg.dart';

class PatientScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const PatientScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _logout(BuildContext context) {
    ApiClient.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiClient.currentUser;
    final patientName =
        user?['full_name'] ?? user?['name'] ?? user?['username'] ?? 'Patient';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      /* ================= APP BAR ================= */
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Text(
              'Patient Dashboard',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 28),
            onSelected: (v) {
              if (v == 'logout') _logout(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'patient',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      /* ================= DRAWER ================= */
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /* ===== HEADER ===== */
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: const BoxDecoration(color: Color(0xFF1E88E5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/logo/smriti-m.svg', height: 40),
                      const SizedBox(width: 12),
                      const Text(
                        'SMRITI-M',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Patient Console',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    patientName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    'patient',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _section('Medication'),
            _item(
              context,
              Icons.today_rounded,
              'Today’s Medications',
              () => _go(context, const PatientLandingScreen()),
            ),
            _item(
              context,
              Icons.chat_bubble_outline,
              'Medication Chat',
              () => _go(context, const PatientChatbotScreen()),
            ),
            _divider(),
            _section('Monitoring'),
            _item(
              context,
              Icons.warning_amber_rounded,
              'Safety Alerts',
              () => _go(context, const AlertsScreen(apiPath: '/alerts')),
            ),
            const SizedBox(height: 20),

            /* 🌗 DARK MODE */
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, mode, __) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: mode == ThemeMode.dark,
                  onChanged: (v) {
                    themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
            
            /* 🔐 BIOMETRIC */
            _BiometricToggle(),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'SMRITI-M © 2026',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      /* ================= BODY + FOOTER ================= */
      body: Column(
        children: [
          Expanded(child: body),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'SMRITI-M © 2026',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ===== helpers ===== */

  Widget _item(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);
}

/* =====================================================
   BIOMETRIC TOGGLE WIDGET
===================================================== */
class _BiometricToggle extends StatefulWidget {
  const _BiometricToggle();

  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
  bool supported = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    supported = await BiometricAuth.isSupported();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Biometric Login'),
      subtitle: Text(
        supported
            ? 'Use fingerprint/face authentication'
            : 'Not supported on this device',
        style: const TextStyle(fontSize: 12),
      ),
      value: ApiClient.biometricEnabled,
      onChanged: supported
          ? (v) async {
              if (v) {
                // Authenticate before enabling
                final authenticated = await BiometricAuth.authenticate();
                if (!authenticated) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Authentication failed')),
                    );
                  }
                  return;
                }
              }
              await ApiClient.enableBiometric(v);
              if (mounted) setState(() {});
            }
          : null,
    );
  }
}
