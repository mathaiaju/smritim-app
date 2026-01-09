import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';

class AlertDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> alert;

  const AlertDetailsScreen({super.key, required this.alert});

  @override
  State<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends State<AlertDetailsScreen> {
  Map<String, dynamic>? pvpiCase;
  List<String> reportedSymptoms = [];

  bool loading = true;
  bool creatingPvpi = false;
  bool submittingPvpi = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  /* =====================================================
     LOAD EVERYTHING
  ===================================================== */
  Future<void> _loadAll() async {
    await _loadPvpiForAlert();
    await _loadSymptomsFromDailyLogs();
    if (mounted) setState(() => loading = false);
  }

  /* =====================================================
     LOAD PvPI CASE
  ===================================================== */
  Future<void> _loadPvpiForAlert() async {
    try {
      final res = await ApiClient.get('/pvpi');
      final List cases = jsonDecode(res.body);

      final a = widget.alert;

      for (final c in cases) {
        if (c['user_id'] == a['user_id'] &&
            c['medication_id'] == a['medication_id'] &&
            c['medication_schedule_id'] == a['medication_schedule_id']) {
          pvpiCase = c;
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ PvPI load failed: $e');
    }
  }

  /* =====================================================
     LOAD SYMPTOMS FROM DAILY LOGS
  ===================================================== */
  Future<void> _loadSymptomsFromDailyLogs() async {
    try {
      final a = widget.alert;

      final res = await ApiClient.get(
        '/daily-logs'
        '?user_id=${a['user_id']}'
        '&medication_id=${a['medication_id']}'
        '&medication_schedule_id=${a['medication_schedule_id']}',
      );

      final List logs = jsonDecode(res.body);
      final Set<String> symptoms = {};

      for (final log in logs) {
        final List quick = log['quick_se'] ?? [];
        for (final s in quick) {
          symptoms.add(s.toString());
        }
      }

      reportedSymptoms = symptoms.toList();
    } catch (e) {
      debugPrint('❌ Daily log load failed: $e');
    }
  }

  /* =====================================================
     CREATE PvPI (Clinician)
  ===================================================== */
  Future<void> _createPvpi() async {
    setState(() => creatingPvpi = true);

    final res = await ApiClient.postJson(
      '/pvpi/from-alert',
      {
        'alert_id': widget.alert['id'],
        'seriousness': 'serious',
      },
    );

    if (res.statusCode == 201) {
      await _loadAll();
    }

    setState(() => creatingPvpi = false);
  }

  /* =====================================================
     SUBMIT PvPI (Admin)
  ===================================================== */
  Future<void> _submitPvpi() async {
    if (pvpiCase == null) return;

    setState(() => submittingPvpi = true);

    try {
      final res = await ApiClient.postJson(
        '/pvpi/submit',
        {"case_id": pvpiCase!['id']},
      );

      if (res.statusCode == 200) {
        pvpiCase!['submitted_to_pvpi'] = true;
        pvpiCase!['submitted_at'] = DateTime.now().toIso8601String();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PvPI case submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit PvPI'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => submittingPvpi = false);
    }
  }

  String _fmt(dynamic v) {
    if (v == null) return '-';
    if (v is String && v.length >= 10) return v.substring(0, 10);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    final medication = a['Medication'];
    final patient = a['User'];
    final rule = a['Rule'];
    final role = ApiClient.currentUser?['role'];

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Details')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('Alert'),
                      Text(a['description'] ?? '-'),
                      const Divider(height: 30),
                      if (patient != null) ...[
                        _section('Patient'),
                        Text(patient['full_name']),
                        const SizedBox(height: 16),
                      ],
                      if (medication != null) ...[
                        _section('Medication'),
                        Text(
                            '${medication['drug_name_generic']} (${medication['drug_name_brand'] ?? '-'})'),
                        Text('Medication ID: ${medication['id']}'),
                        Text('Schedule ID: ${a['medication_schedule_id']}'),
                        const SizedBox(height: 16),
                      ],
                      if (rule != null) ...[
                        _section('Clinical Action'),
                        Text(rule['action_card']),
                      ],
                      const Divider(height: 30),
                      if (pvpiCase != null) _pvpiDetails(),
                      if (pvpiCase == null && role == 'clinician')
                        _createButton(),
                      if (pvpiCase != null &&
                          role == 'hospital_admin' &&
                          pvpiCase!['submitted_to_pvpi'] != true)
                        _submitButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _pvpiDetails() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('PvPI Case'),
            Text('Case ID: #${pvpiCase!['id']}'),
            Text('Created on: ${_fmt(pvpiCase!['created_at'])}'),
            const SizedBox(height: 8),
            const Text(
              'Symptoms reported by patient:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (reportedSymptoms.isEmpty)
              const Text('-')
            else
              ...reportedSymptoms.map((s) => Text('• $s')),
          ],
        ),
      ),
    );
  }

  Widget _createButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.assignment),
      label: Text(creatingPvpi ? 'Creating...' : 'Create PvPI Case'),
      onPressed: creatingPvpi ? null : _createPvpi,
    );
  }

  Widget _submitButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.send),
      label: Text(submittingPvpi ? 'Submitting...' : 'Submit to PvPI'),
      onPressed: submittingPvpi ? null : _submitPvpi,
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
