import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';
import 'pvpi_case_details_screen.dart';

class PvpiCasesScreen extends StatelessWidget {
  const PvpiCasesScreen({super.key});

  Color seriousnessColor(String seriousness) {
    switch (seriousness) {
      case 'serious':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Icon statusIcon(bool submitted) {
    return submitted
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.hourglass_top, color: Colors.orange);
  }

  String statusText(bool submitted) {
    return submitted ? "Submitted to PvPI" : "Pending Review";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("PvPI Adverse Event Cases")),
      body: Column(
        children: [
          const AppHeader(
            subtitle: 'Pharmacovigilance reporting & review',
          ),
          Expanded(
            child: FutureBuilder(
              future: ApiClient.get('/pvpi'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final response = snapshot.data as dynamic;
                final List cases = jsonDecode(response.body);

                if (cases.isEmpty) {
                  return const Center(
                    child: Text(
                      "No PvPI cases reported yet",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cases.length,
                  itemBuilder: (_, i) {
                    final c = cases[i];

                    return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PvpiCaseDetailsScreen(pvpiCase: c),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 6,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c['original_term'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    statusIcon(c['submitted_to_pvpi']),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        c['seriousness'].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: seriousnessColor(
                                        c['seriousness'],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      statusText(c['submitted_to_pvpi']),
                                      style: TextStyle(
                                        color: c['submitted_to_pvpi']
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Reported on: ${c['log_date']}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
