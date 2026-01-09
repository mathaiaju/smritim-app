import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api_client.dart';
import 'add_schedule_screen.dart';

class AddMedicationScreen extends StatefulWidget {
  final int patientId;

  const AddMedicationScreen({super.key, required this.patientId});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  bool loading = true;
  List<Map<String, dynamic>> medications = [];

  final genericCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final indicationCtrl = TextEditingController();

  /// 🔍 drug assist
  List<String> drugSuggestions = [];
  List<String> drugSymptoms = [];
  bool searchingDrugs = false;

  DateTime startDate = DateTime.now();
  DateTime? stopDate;

  bool submitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMedications();
  }

  /* =====================================================
     LOAD MEDICATIONS (UNCHANGED)
  ===================================================== */
  Future<void> loadMedications() async {
    setState(() => loading = true);

    try {
      final res = await ApiClient.get('/meds?user_id=${widget.patientId}');
      final decoded = jsonDecode(res.body);

      if (decoded is! List) {
        setState(() {
          medications = [];
          loading = false;
        });
        return;
      }

      setState(() {
        medications = decoded.cast<Map<String, dynamic>>();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  /* =====================================================
     🔍 DRUG AUTOCOMPLETE
  ===================================================== */
  Future<void> searchDrugs(String q) async {
    if (q.length < 2) {
      setState(() {
        drugSuggestions = [];
        drugSymptoms = [];
      });
      return;
    }

    try {
      final res = await ApiClient.get('/drugs/search?q=$q');
      final decoded = jsonDecode(res.body);

      setState(() {
        drugSuggestions = List<String>.from(decoded['drugs'] ?? <String>[]);
      });
    } catch (_) {
      setState(() => drugSuggestions = []);
    }
  }

  Future<void> loadDrugSymptoms(String drug) async {
    try {
      final res = await ApiClient.get('/drugs/$drug/symptoms');
      final decoded = jsonDecode(res.body);

      setState(() {
        drugSymptoms = List<String>.from(decoded['symptoms'] ?? <String>[]);
      });
    } catch (_) {
      setState(() => drugSymptoms = []);
    }
  }

  /* =====================================================
     DATE PICKERS (UNCHANGED)
  ===================================================== */
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickStopDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: stopDate ?? startDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => stopDate = picked);
  }

  /* =====================================================
     SUBMIT (UNCHANGED)
  ===================================================== */
  Future<void> submit() async {
    if (genericCtrl.text.trim().isEmpty) {
      setState(() => error = 'Generic name is required');
      return;
    }

    setState(() {
      submitting = true;
      error = null;
    });

    try {
      final res = await ApiClient.postJson('/meds', {
        "user_id": widget.patientId,
        "drug_name_generic": genericCtrl.text.trim(),
        "drug_name_brand": brandCtrl.text.trim(),
        "indication": indicationCtrl.text.trim(),
        "start_date": DateFormat('yyyy-MM-dd').format(startDate),
        "stop_date": stopDate != null
            ? DateFormat('yyyy-MM-dd').format(stopDate!)
            : null,
      });

      if (res.statusCode != 201) {
        setState(() => error = 'Failed to save medication');
        return;
      }

      final created = jsonDecode(res.body);
      final int medicationId = created['id'];

      genericCtrl.clear();
      brandCtrl.clear();
      indicationCtrl.clear();
      drugSymptoms.clear();
      stopDate = null;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddScheduleScreen(medicationId: medicationId),
        ),
      );

      await loadMedications();
    } catch (_) {
      setState(() => error = 'Network error');
    } finally {
      setState(() => submitting = false);
    }
  }

  /* =====================================================
     UI
  ===================================================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (medications.isNotEmpty) ...[
                  const Text(
                    'Existing Medications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...medications.map(_existingMedicationCard),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Add New Medication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔍 GENERIC NAME AUTOCOMPLETE
                        TextField(
                          controller: genericCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Generic Name *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: searchDrugs,
                        ),

                        if (drugSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                )
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: drugSuggestions.length,
                              itemBuilder: (_, i) {
                                final drug = drugSuggestions[i];
                                return ListTile(
                                  title: Text(drug),
                                  onTap: () {
                                    genericCtrl.text = drug;
                                    drugSuggestions.clear();
                                    loadDrugSymptoms(drug);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),

                        if (drugSymptoms.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Known Safety Symptoms',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: drugSymptoms
                                .map((s) => Chip(
                                      label: Text(s),
                                      backgroundColor: Colors.orange.shade100,
                                    ))
                                .toList(),
                          ),
                        ],

                        const SizedBox(height: 12),
                        TextField(
                          controller: brandCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Brand Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: indicationCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Indication',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            'Start Date: ${DateFormat('dd MMM yyyy').format(startDate)}',
                          ),
                          onPressed: pickStartDate,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.event_busy),
                          label: Text(
                            stopDate == null
                                ? 'Stop Date: Not set'
                                : 'Stop Date: ${DateFormat('dd MMM yyyy').format(stopDate!)}',
                          ),
                          onPressed: pickStopDate,
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(error!,
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting ? null : submit,
                    child: Text(submitting ? 'Saving...' : 'Add Medication'),
                  ),
                ),
              ],
            ),
    );
  }

  /* =====================================================
     EXISTING MED CARD (UNCHANGED)
  ===================================================== */
  Widget _existingMedicationCard(Map<String, dynamic> m) {
    final schedules = (m['MedicationSchedules'] as List?) ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            m['drug_name_generic'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Start: ${m['start_date']}'
            '${m['stop_date'] != null ? ' • Stop: ${m['stop_date']}' : ''}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (schedules.isNotEmpty)
            ...schedules.map((s) => Text(
                  '• ${s['time_of_day']} at ${s['scheduled_time']} (${s['dose']})',
                  style: const TextStyle(fontSize: 13),
                )),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddScheduleScreen(medicationId: m['id']),
                  ),
                );
                await loadMedications();
              },
              child: const Text('Add Schedule'),
            ),
          ),
        ]),
      ),
    );
  }
}
