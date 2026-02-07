import 'dart:convert';
import 'package:flutter/material.dart';
import 'clinician/add_pvpi_case_screen.dart';
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

  // Store prefilled values in state
  String? hospitalName;
  String? reporterContact;

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
    await _prefetchPrefillData();
    if (mounted) setState(() => loading = false);
  }

  // Prefetch hospital name and reporter contact for PvPI form
  Future<void> _prefetchPrefillData() async {
    final clinician = ApiClient.currentUser;
    debugPrint('Clinician object: ' + (clinician != null ? clinician.toString() : 'null'));
    String? hName = clinician?['hospital_name'];
    if ((hName == null || hName.isEmpty) && clinician?['hospital_id'] != null) {
      hName = await _fetchHospitalName(clinician?['hospital_id']);
    }
    String? rContact = clinician?['phone'] ?? clinician?['contact_number'] ?? '';
    // Try to get clinician id from alert if not present in currentUser
    final alertClinicianId = widget.alert['clinician_id'] ?? widget.alert['user_id'];
    final fetchClinicianId = clinician?['id'] ?? alertClinicianId;
    debugPrint('Initial reporterContact: ' + (rContact ?? 'null'));
    debugPrint('Clinician id for contact fetch: ' + (fetchClinicianId?.toString() ?? 'null'));
    if ((rContact == null || rContact.isEmpty) && fetchClinicianId != null) {
      rContact = await _fetchClinicianContact(fetchClinicianId);
      debugPrint('Fetched reporterContact from /clinicians: ' + (rContact ?? 'null'));
    }
    setState(() {
      hospitalName = hName ?? '';
      reporterContact = rContact ?? '';
    });
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

  Future<String?> _fetchHospitalName(int? hospitalId) async {
    if (hospitalId == null) return null;
    try {
      final res = await ApiClient.get('/hospitals');
      if (res.statusCode == 200) {
        final List hospitals = jsonDecode(res.body);
        final hospital = hospitals.firstWhere(
          (h) => h['id'] == hospitalId,
          orElse: () => null,
        );
        return hospital != null ? hospital['name'] : null;
      }
    } catch (e) {
      debugPrint('Failed to fetch hospital: $e');
    }
    return null;
  }

  Future<String?> _fetchClinicianContact(int? clinicianId) async {
    if (clinicianId == null) return null;
    try {
      final res = await ApiClient.get('/clinicians/$clinicianId');
      if (res.statusCode == 200) {
        final clinician = jsonDecode(res.body);
        return clinician['phone'] ?? clinician['contact_number'] ?? '';
      }
    } catch (e) {
      debugPrint('Failed to fetch clinician contact: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    final medication = a['Medication'];
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
                      if (medication != null) ...[
                        _section('Medication'),
                        Text(
                            '${medication['drug_name_generic']} (${medication['drug_name_brand'] ?? '-'})'),
                        Text('Medication ID: ${medication['id']}'),
                        Text('Schedule ID: ${a['medication_schedule_id']}'),
                        const SizedBox(height: 16),
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
    final caseData = pvpiCase!;
    final detailRows = [
      _detailRow(Icons.assignment, 'Case ID', '#${caseData['id']}'),
      _detailRow(Icons.calendar_today, 'Created on', _fmt(caseData['created_at'])),
      _detailRow(Icons.medical_services, 'Suspected Drug', caseData['suspected_drug']),
      _detailRow(Icons.bug_report, 'Reaction Outcome', caseData['reaction_outcome']),
      _detailRow(Icons.warning_amber_rounded, 'Seriousness', caseData['seriousness']),
      _detailRow(Icons.person, 'Reporter Name', caseData['reporter_name']),
      _detailRow(Icons.phone, 'Reporter Contact', caseData['reporter_contact']),
      _detailRow(Icons.local_hospital, 'Hospital Name', caseData['hospital_name']),
      _detailRow(Icons.info_outline, 'Action Taken', caseData['action_taken']),
      _detailRow(Icons.description, 'ADR Description', caseData['adr_description']),
    ];
    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.verified, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('PvPI Case Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const Divider(height: 24, thickness: 1.2),
            ...detailRows,
            const SizedBox(height: 18),
            const Text(
              'Symptoms reported by patient:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            if (reportedSymptoms.isEmpty)
              const Text('-', style: TextStyle(color: Colors.black54))
            else
              ...reportedSymptoms.map((s) => Row(
                children: [
                  const Icon(Icons.circle, size: 7, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(s, style: const TextStyle(fontSize: 14)),
                ],
              )),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value == null || value.toString().isEmpty ? '-' : value.toString(),
              style: const TextStyle(color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createButton() {
    final canCreate = (hospitalName != null && hospitalName!.isNotEmpty && reporterContact != null && reporterContact!.isNotEmpty);
    final missingFields = <String>[];
    if (hospitalName == null || hospitalName!.isEmpty) missingFields.add('Hospital Name');
    if (reporterContact == null || reporterContact!.isEmpty) missingFields.add('Reporter Contact');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.assignment),
          label: Text(creatingPvpi ? 'Creating...' : 'Create PvPI Case'),
          onPressed: (!canCreate || creatingPvpi)
              ? null
              : () async {
                  setState(() => creatingPvpi = true);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  final a = widget.alert;
                  final medication = a['Medication'];
                  final clinician = ApiClient.currentUser;
                  final symptoms = reportedSymptoms;

                  final suspectedDrug = medication != null
                      ? (medication['drug_name_generic'] ?? medication['drug_name_brand'] ?? '')
                      : '';
                  final reactionOutcome = symptoms.isNotEmpty ? symptoms.join(', ') : (a['description'] ?? '');
                  final reporterName = clinician?['full_name'] ?? clinician?['username'] ?? '';
                  final seriousness = a['severity'] ?? a['seriousness'] ?? '';

                  // Use prefetched values
                  final prefill = {
                    'adr_description': '',
                    'suspected_drug': suspectedDrug,
                    'reaction_outcome': reactionOutcome,
                    'seriousness': seriousness,
                    'reporter_name': reporterName,
                    'reporter_contact': reporterContact ?? '',
                    'hospital_name': hospitalName ?? '',
                  };

                  Navigator.of(context).pop(); // Remove loading dialog
                  setState(() => creatingPvpi = false);

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPvpiCaseScreen(
                        prefill: prefill.map((k, v) => MapEntry(k, v.toString())),
                      ),
                      settings: RouteSettings(arguments: a['id']), // Pass alert_id as argument
                    ),
                  );
                  if (result == true) {
                    await _loadAll();
                    setState(() {});
                  }
                },
        ),
        if (!canCreate && missingFields.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Cannot create PvPI case: missing ${missingFields.join(' and ')}.\nPlease contact admin.',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
      ],
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
