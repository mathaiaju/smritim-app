import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';

class LinkPatientClinicianScreen extends StatefulWidget {
  const LinkPatientClinicianScreen({super.key});

  @override
  State<LinkPatientClinicianScreen> createState() =>
      _LinkPatientClinicianScreenState();
}

class _LinkPatientClinicianScreenState
    extends State<LinkPatientClinicianScreen> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> clinicians = [];

  int? selectedPatientId;
  int? selectedClinicianId;

  bool loading = true;
  bool submitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final patientRes = await ApiClient.get('/users');
      final clinicianRes = await ApiClient.get('/clinicians');

      final patientDecoded = jsonDecode(patientRes.body);
      final clinicianDecoded = jsonDecode(clinicianRes.body);

      // 🔑 IMPORTANT FIX
      patients = List<Map<String, dynamic>>.from(
        patientDecoded['users'] ?? [],
      );

      clinicians = List<Map<String, dynamic>>.from(
        clinicianDecoded is List
            ? clinicianDecoded
            : clinicianDecoded['clinicians'] ?? [],
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
    if (selectedPatientId == null || selectedClinicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both patient and clinician'),
          backgroundColor: Colors.red.shade600,
        ),
      );

      return;
    }

    setState(() => submitting = true);

    try {
      final res = await ApiClient.postJson(
        '/users/patient-clinician',
        {
          "user_id": selectedPatientId,
          "clinician_id": selectedClinicianId,
        },
      );

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Patient linked to clinician'),
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
      appBar: AppBar(title: const Text('Link Patient → Clinician')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Patient',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedPatientId,
                        items: patients
                            .map(
                              (p) => DropdownMenuItem<int>(
                                value: p['id'],
                                child:
                                    Text('${p['full_name']} (${p['phone']})'),
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
                      const Text('Clinician',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedClinicianId,
                        items: clinicians
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c['id'],
                                child: Text(c['full_name']),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedClinicianId = v),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select clinician',
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitting ? null : _submit,
                          child: submitting
                              ? const CircularProgressIndicator()
                              : const Text('Link Patient'),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
