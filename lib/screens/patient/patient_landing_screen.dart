import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';
import 'patient_chatbot_screen.dart';
import '../../widgets/patient_scaffold.dart';

class PatientLandingScreen extends StatefulWidget {
  const PatientLandingScreen({super.key});

  @override
  State<PatientLandingScreen> createState() => _PatientLandingScreenState();
}

class _PatientLandingScreenState extends State<PatientLandingScreen> {
  bool loading = true;
  List<Map<String, dynamic>> meds = [];
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotifications();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    await Future.wait([
      _loadTodayMeds(),
      _loadNotifications(),
    ]);
    if (mounted) setState(() => loading = false);
  }

  /* ================= TODAY’S MEDS ================= */
  Future<void> _loadTodayMeds() async {
    try {
      final res = await ApiClient.get('/patient/chatbot/today-schedules');
      final decoded = jsonDecode(res.body);
      meds = List<Map<String, dynamic>>.from(decoded['schedules'] ?? []);
    } catch (_) {
      meds = [];
    }
  }

  /* ================= ALERTS ================= */
  Future<void> _loadNotifications() async {
    try {
      final res = await ApiClient.get('/alerts');
      final decoded = jsonDecode(res.body);
      notifications = List<Map<String, dynamic>>.from(decoded['alerts'] ?? []);
      if (mounted) setState(() {});
    } catch (_) {
      notifications = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PatientScaffold(
      title: 'Patient Home',

      /// 🔑 BODY CONTAINS FAB USING STACK
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadData,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    children: [
                      /* ---------- NOTIFICATIONS ---------- */
                      const Text(
                        'Notifications',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (notifications.isEmpty)
                        _EmptyCard(text: 'No new notifications')
                      else
                        ...notifications.map(_NotificationCard),
                      const SizedBox(height: 24),

                      /* ---------- TODAY’S MEDICATIONS ---------- */
                      const Text(
                        'Today’s Medications',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      if (meds.isEmpty)
                        _EmptyCard(
                            text: '🎉 No medications scheduled for today')
                      else
                        ...meds.map(_MedicationCard),
                      const SizedBox(height: 24),

                      /* ---------- FOOTER ---------- */
                      /*Center(
                          child: Text(
                            'SMRITI-M © 2026',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),*/
                    ],
                  ),
          ),

          /* ================= CHATBOT FAB ================= */
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientChatbotScreen(),
                  ),
                ).then((_) => _loadData());
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ================= UI CARDS ================= */

  Widget _NotificationCard(Map<String, dynamic> n) {
    final severity = n['Rule']?['severity'] ?? 'info';

    final color = severity == 'high'
        ? Colors.red
        : severity == 'medium'
            ? Colors.orange
            : Colors.blue;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(Icons.warning, color: color),
        title: Text(
          n['description'] ?? 'Alert',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(n['Medication']?['drug_name_generic'] ?? ''),
      ),
    );
  }

  Widget _MedicationCard(Map<String, dynamic> m) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.medication, color: Colors.blue),
        ),
        title: Text(
          m['drug_name'] ?? 'Medication',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Dose: ${m['dose']}'),
            Text(
              '🕒 ${m['scheduled_time']} • '
              '${m['after_food'] == true ? 'After food' : 'Before food'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _EmptyCard({required String text}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
