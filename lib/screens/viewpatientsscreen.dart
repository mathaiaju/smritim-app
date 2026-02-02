import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smritim_app/screens/clinician/add_medication_screen.dart';
import '../api_client.dart';

class ViewPatientsScreen extends StatelessWidget {
  const ViewPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text("Patients"),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: FutureBuilder(
        future: ApiClient.get('/users'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final res = snapshot.data as dynamic;

          if (res.statusCode != 200) {
            return const Center(
              child: Text("Failed to load patients"),
            );
          }

          final decoded = jsonDecode(res.body);

          // 🛡️ Defensive parsing
          final List patients = decoded is Map && decoded['users'] is List
              ? decoded['users']
              : [];

          if (patients.isEmpty) {
            return const Center(
              child: Text("No patients found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: patients.length,
            itemBuilder: (_, i) {
              final Map p = patients[i];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ================= HEADER =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p['full_name'] ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _formatVitals(p),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text("📞 ${p['phone']}"),

                      const Divider(height: 20),

                      /// ================= CLINICIANS =================
                      FutureBuilder(
                        future: ApiClient.get(
                          '/users/${p['id']}/clinicians',
                        ),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text(
                              "Clinicians: loading...",
                              style: TextStyle(fontSize: 12),
                            );
                          }

                          final r = snap.data as dynamic;
                          final List clinicians = jsonDecode(r.body);

                          if (clinicians.isEmpty) {
                            return const Text(
                              "Clinicians: Not assigned",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: clinicians.map((c) {
                              return Chip(
                                label: Text(
                                  c['clinician']['full_name'],
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: const Color(0xFFE0E7FF),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      /// ================= ACTIONS =================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.medical_services),
                          label: const Text("Manage Medications"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddMedicationScreen(
                                  patientId: p['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// =====================================================
/// 🧮 AGE + WEIGHT FORMATTER (SAFE)
/// =====================================================
String _formatVitals(Map p) {
  final age = p['age'] != null ? "${p['age']} yrs" : null;

  final weight = p['weight_kg'] != null ? "${p['weight_kg']} kg" : null;

  if (age != null && weight != null) {
    return "$age • $weight";
  }

  return age ?? weight ?? "—";
}
