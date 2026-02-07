import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/dashboard_tile.dart';
import '../widgets/admin_scaffold.dart'; // ✅ NEW

import 'login_screen.dart';
import 'add_patient_screen.dart';
import 'add_clinician_screen.dart';
import 'add_caregiver_screen.dart';
import 'link_patient_clinician_screen.dart';
import 'link_patient_caregiver_screen.dart';
import 'alerts_screen.dart';
import 'pvpi_cases_screen.dart';
import 'viewpatientsscreen.dart';
import 'viewcliniciansscreen.dart';
import 'viewcaregiversscreen.dart';
import 'viewadminsscreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool loading = true;
  String hospitalName = '';
  int patients = 0;
  int clinicians = 0;
  int caregivers = 0;
  int alerts = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final res = await ApiClient.get('/admin/dashboard-stats');
      final decoded = jsonDecode(res.body);

      setState(() {
        hospitalName = decoded['hospital_name'] ?? '';
        patients = decoded['patients'] ?? 0;
        clinicians = decoded['clinicians'] ?? 0;
        caregivers = decoded['caregivers'] ?? 0;
        alerts = decoded['alerts'] ?? 0;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load dashboard statistics'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'SMRITI-M Admin Dashboard',
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _DashboardHeader(
                    hospitalName: hospitalName,
                    patients: patients,
                    clinicians: clinicians,
                    caregivers: caregivers,
                    alerts: alerts,
                  ),

                  /// ======================
                  /// 📁 DIRECTORY
                  /// ======================
                  const _SectionHeader(title: 'User Directory'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _grid([
                      DashboardTile(
                        icon: Icons.person,
                        label: 'Patients',
                        color: Colors.blue.shade600,
                        onTap: () => _go(const ViewPatientsScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.medical_services,
                        label: 'Clinicians',
                        color: Colors.teal.shade600,
                        onTap: () => _go(const ViewCliniciansScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.groups,
                        label: 'Caregivers',
                        color: Colors.indigo.shade600,
                        onTap: () => _go(const ViewCaregiversScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.admin_panel_settings,
                        label: 'Admins',
                        color: Colors.orange.shade700,
                        onTap: () => _go(const ViewAdminsScreen()),
                      ),
                    ]),
                  ),

                  /// ======================
                  /// 👤 PEOPLE MANAGEMENT
                  /// ======================
                  const _SectionHeader(title: 'People Management'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _grid([
                      DashboardTile(
                        icon: Icons.person_add,
                        label: 'Add Patient',
                        color: Colors.blue.shade600,
                        onTap: () => _go(const AddPatientScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.medical_services_outlined,
                        label: 'Add Clinician',
                        color: Colors.teal.shade600,
                        onTap: () => _go(const AddClinicianScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.groups_outlined,
                        label: 'Add Caregiver',
                        color: Colors.indigo.shade600,
                        onTap: () => _go(const AddCaregiverScreen()),
                      ),
                    ]),
                  ),

                  /// ======================
                  /// 🔗 RELATIONSHIPS
                  /// ======================
                  const _SectionHeader(title: 'Patient Relationships'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _grid([
                      DashboardTile(
                        icon: Icons.link,
                        label: 'Patient → Clinician',
                        color: Colors.deepPurple.shade600,
                        onTap: () => _go(const LinkPatientClinicianScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.family_restroom,
                        label: 'Patient → Caregiver',
                        color: Colors.brown.shade600,
                        onTap: () => _go(const LinkPatientCaregiverScreen()),
                      ),
                    ]),
                  ),

                  /// ======================
                  /// 🚨 MONITORING
                  /// ======================
                  const _SectionHeader(title: 'Monitoring & Safety'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _grid([
                      DashboardTile(
                        icon: Icons.warning_amber_rounded,
                        label: 'Safety Alerts',
                        color: Colors.red.shade600,
                        onTap: () => _go(const AlertsScreen()),
                      ),
                      DashboardTile(
                        icon: Icons.assignment_outlined,
                        label: 'PvPI Cases',
                        color: Colors.orange.shade700,
                        onTap: () => _go(const PvpiCasesScreen()),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _grid(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: children,
      ),
    );
  }

  void _logout(BuildContext context) {
    ApiClient.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

/// =======================================================
/// 🧠 DASHBOARD HEADER
/// =======================================================
class _DashboardHeader extends StatelessWidget {
  final String hospitalName;
  final int patients;
  final int clinicians;
  final int caregivers;
  final int alerts;

  const _DashboardHeader({
    required this.hospitalName,
    required this.patients,
    required this.clinicians,
    required this.caregivers,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hospital', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                hospitalName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatTile('Patients', patients, Colors.blue.shade600),
                  _StatTile('Clinicians', clinicians, Colors.teal.shade600),
                  _StatTile('Caregivers', caregivers, Colors.indigo.shade600),
                  _StatTile('Alerts', alerts, Colors.red.shade600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}