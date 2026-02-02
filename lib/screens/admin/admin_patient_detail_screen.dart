import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../medication/add_medication_screen.dart';
import '../medication/add_schedule_screen.dart';

class AdminPatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const AdminPatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final int patientId = patient['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Medications • ${patient['full_name'] ?? ''}"),
      ),
      body: Column(
        children: [
          /// 📋 EXISTING MEDICATIONS
          Expanded(
            child: FutureBuilder(
              future: ApiClient.get('/meds?user_id=$patientId'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final res = snapshot.data as dynamic;

                if (res.statusCode != 200) {
                  return const Center(
                    child: Text("Failed to load medications"),
                  );
                }

                final List meds = jsonDecode(res.body);

                if (meds.isEmpty) {
                  return const Center(
                    child: Text("No medications added yet"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: meds.length,
                  itemBuilder: (_, i) {
                    final m = meds[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          m['drug_name_generic'] ?? 'Medication',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          m['drug_name_brand'] != null
                              ? "Brand: ${m['drug_name_brand']}"
                              : "Generic only",
                        ),
                        trailing: ElevatedButton(
                          child: const Text("Add Schedule"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddScheduleScreen(
                                  medicationId: m['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ➕ ADD NEW MEDICATION (PRIMARY CTA)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add New Medication"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMedicationScreen(patientId: patientId),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
