import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';

class LinkPatientCaregiverScreen extends StatefulWidget {
  const LinkPatientCaregiverScreen({super.key});

  @override
  State<LinkPatientCaregiverScreen> createState() =>
      _LinkPatientCaregiverScreenState();
}

class _LinkPatientCaregiverScreenState
    extends State<LinkPatientCaregiverScreen> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> caregivers = [];

  int? selectedPatientId;
  int? selectedCaregiverId;

  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final patientRes = await ApiClient.get('/users');
      final caregiverRes = await ApiClient.get('/caregivers');

      final patientDecoded = jsonDecode(patientRes.body);
      final caregiverDecoded = jsonDecode(caregiverRes.body);

      patients = List<Map<String, dynamic>>.from(
        patientDecoded['users'] ?? [],
      );

      caregivers = List<Map<String, dynamic>>.from(
        caregiverDecoded is List
            ? caregiverDecoded
            : caregiverDecoded['caregivers'] ?? [],
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load dropdown data'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _submit() async {
    if (selectedPatientId == null || selectedCaregiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both patient and caregiver'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      final res = await ApiClient.postJson(
        '/users/patient-caregiver',
        {
          "user_id": selectedPatientId,
          "caregiver_id": selectedCaregiverId,
        },
      );

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Caregiver linked to patient'),
            backgroundColor: Colors.green.shade600,
          ),
        );
        Navigator.pop(context);
      } else {
        final decoded = jsonDecode(res.body);
        throw Exception(decoded['error'] ?? 'Linking failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Patient → Caregiver')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedPatientId,
                    items: patients
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p['id'],
                            child: Text('${p['full_name']} (${p['phone']})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedPatientId = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select patient',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Caregiver',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedCaregiverId,
                    items: caregivers
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text(c['full_name']),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedCaregiverId = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select caregiver',
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const CircularProgressIndicator()
                          : const Text('Link Caregiver'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
