import 'package:flutter/material.dart';

class PvpiCaseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pvpiCase;

  const PvpiCaseDetailsScreen({super.key, required this.pvpiCase});

  @override
  Widget build(BuildContext context) {
    final med = pvpiCase['Medication'];
    final patient = pvpiCase['User'];

    return Scaffold(
      appBar: AppBar(title: const Text('PvPI Case Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pvpiCase['original_term'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Seriousness: ${pvpiCase['seriousness']}'),
                Text('Outcome: ${pvpiCase['outcome']}'),
                const Divider(height: 30),
                if (patient != null) ...[
                  const Text('Patient',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(patient['full_name']),
                  const SizedBox(height: 16),
                ],
                if (med != null) ...[
                  const Text('Medication',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(med['drug_name_generic']),
                  const SizedBox(height: 16),
                ],
                Chip(
                  label: Text(
                    pvpiCase['submitted_to_pvpi']
                        ? 'SUBMITTED TO PvPI'
                        : 'PENDING SUBMISSION',
                  ),
                  backgroundColor: pvpiCase['submitted_to_pvpi']
                      ? Colors.green
                      : Colors.orange,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
