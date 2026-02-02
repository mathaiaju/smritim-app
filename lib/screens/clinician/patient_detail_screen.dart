import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';
import 'add_medication_screen.dart';
import 'weekly_adherence_detail_screen.dart';
import 'symptom_breakdown_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool loading = true;
  bool exporting = false;

  int adherencePercent = 0;
  int totalLogs = 0;
  List<Map<String, dynamic>> topSymptoms = [];

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    try {
      final id = widget.patient['id'];

      final adherenceRes =
          await ApiClient.get('/clinicians/patient/$id/adherence-summary');
      final symptomsRes =
          await ApiClient.get('/clinicians/patient/$id/top-symptoms');

      final adherenceJson = jsonDecode(adherenceRes.body);
      final symptomsJson = jsonDecode(symptomsRes.body);

      setState(() {
        adherencePercent = adherenceJson['adherence_percent'] ?? 0;
        totalLogs = adherenceJson['total_expected'] ?? 0;
        topSymptoms =
            List<Map<String, dynamic>>.from(symptomsJson['symptoms'] ?? []);
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> exportPdf() async {
    setState(() => exporting = true);
    try {
      await ApiClient.download(
        '/clinicians/patient/${widget.patient['id']}/export-pdf',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export PDF'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.patient['full_name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            icon: exporting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            onPressed: exporting ? null : exportPdf,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PatientHeader(patient: widget.patient),
                const SizedBox(height: 20),

                /// 📊 WEEKLY ADHERENCE (DRILL DOWN)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WeeklyAdherenceDetailScreen(
                          patient: widget.patient,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          _AdherenceRing(percent: adherencePercent),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Weekly Adherence',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$totalLogs scheduled dose${totalLogs == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to view details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🧠 SYMPTOMS (DRILL DOWN)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SymptomBreakdownScreen(
                          patientId: widget.patient['id'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top Reported Symptoms',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (topSymptoms.isEmpty)
                            const Text(
                              'No symptoms reported this week',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: topSymptoms.map((s) {
                                return Chip(
                                  label: Text('${s['name']} (${s['count']})'),
                                  backgroundColor: Colors.deepOrange.shade50,
                                  labelStyle: TextStyle(
                                    color: Colors.deepOrange.shade700,
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to view details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// ➕ ADD MEDICATION [MOVING THIS TO ADMIN]
                /* ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'View Medications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMedicationScreen(
                          patientId: widget.patient['id'],
                        ),
                      ),
                    );
                    if (changed == true) loadSummary();
                  },
                ),*/
              ],
            ),
    );
  }
}

/// ===============================
/// 👤 PATIENT HEADER
/// ===============================
class _PatientHeader extends StatelessWidget {
  final Map patient;

  const _PatientHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            patient['full_name'][0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          patient['full_name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(patient['phone']),
      ),
    );
  }
}

/// ===============================
/// 📊 FIXED ADHERENCE RING
/// ===============================
class _AdherenceRing extends StatelessWidget {
  final int percent;

  const _AdherenceRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent >= 80
        ? Colors.green
        : percent >= 50
            ? Colors.orange
            : Colors.red;

    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              '$percent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
