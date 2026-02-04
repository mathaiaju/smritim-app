import 'package:flutter/material.dart';
import '../api_client.dart';

import '../screens/login_screen.dart';
import '../screens/viewpatientsscreen.dart';
import '../screens/viewcliniciansscreen.dart';
import '../screens/viewcaregiversscreen.dart';
import '../screens/viewadminsscreen.dart';
import '../screens/add_patient_screen.dart';
import '../screens/add_clinician_screen.dart';
import '../screens/add_caregiver_screen.dart';
import '../screens/link_patient_clinician_screen.dart';
import '../screens/link_patient_caregiver_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/pvpi_cases_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import '../screens/settings/settings_screen.dart';
import '../utils/biometric_auth.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AdminScaffold({
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

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /* ================= APP BAR ================= */
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 28),
            onSelected: (v) {
              if (v == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              }
              if (v == 'logout') _logout(context);
            },
            itemBuilder: (_) => [
              /// 👤 USER INFO (DISABLED)
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?['username'] ?? 'Admin',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?['role'] ?? 'hospital_admin',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              /// ⚙️ SETTINGS
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),

              /// 🚪 LOGOUT
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
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/logo/smriti-m.svg',
                        height: 40,
                      ),
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
                    'Admin Console',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?['username'] ?? 'Admin',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    user?['role'] ?? 'hospital_admin',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _section('User Directory'),
            _item(context, Icons.person, 'Patients',
                () => _go(context, const ViewPatientsScreen())),
            _item(context, Icons.medical_services, 'Clinicians',
                () => _go(context, const ViewCliniciansScreen())),
            _item(context, Icons.groups, 'Caregivers',
                () => _go(context, const ViewCaregiversScreen())),
            _item(context, Icons.admin_panel_settings, 'Admins',
                () => _go(context, const ViewAdminsScreen())),
            _divider(),
            _section('People Management'),
            _item(context, Icons.person_add, 'Add Patient',
                () => _go(context, const AddPatientScreen())),
            _item(context, Icons.medical_services_outlined, 'Add Clinician',
                () => _go(context, const AddClinicianScreen())),
            _item(context, Icons.groups_outlined, 'Add Caregiver',
                () => _go(context, const AddCaregiverScreen())),
            _divider(),
            _section('Patient Relationships'),
            _item(context, Icons.link, 'Patient → Clinician',
                () => _go(context, const LinkPatientClinicianScreen())),
            _item(context, Icons.family_restroom, 'Patient → Caregiver',
                () => _go(context, const LinkPatientCaregiverScreen())),
            _divider(),
            _section('Monitoring'),
            _item(context, Icons.warning_amber_rounded, 'Safety Alerts',
                () => _go(context, const AlertsScreen())),
            _item(context, Icons.assignment_outlined, 'PvPI Cases',
                () => _go(context, const PvpiCasesScreen())),
            const SizedBox(height: 24),

            /// 🌗 DARK MODE TOGGLE
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
            
            /// 🔐 BIOMETRIC TOGGLE
            _BiometricToggle(),

            /* ===== FOOTER ===== */
            Center(
              child: Text(
                'SMRITI-M © 2026',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      /* ================= BODY + FOOTER ================= */
      body: Column(
        children: [
          Expanded(child: body),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
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

      /* ================= BODY ================= */
      //body: body,
    );
  }

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
