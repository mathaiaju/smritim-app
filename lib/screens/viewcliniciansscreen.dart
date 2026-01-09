import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';

class ViewCliniciansScreen extends StatelessWidget {
  const ViewCliniciansScreen({super.key});

  Future<List> loadClinicians() async {
    final res = await ApiClient.get('/clinicians');
    return jsonDecode(res.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinicians')),
      body: FutureBuilder(
        future: loadClinicians(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clinicians = snapshot.data as List;

          if (clinicians.isEmpty) {
            return const Center(child: Text('No clinicians found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clinicians.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final c = clinicians[i];
              return ListTile(
                leading: const Icon(Icons.medical_services),
                title: Text(c['full_name'] ?? '-'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c['email'] != null) Text(c['email']),
                    if (c['phone'] != null) Text('📞 ${c['phone']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Edit clinician
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Disable clinician (soft delete)
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
