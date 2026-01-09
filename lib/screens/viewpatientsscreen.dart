import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';

class ViewPatientsScreen extends StatelessWidget {
  const ViewPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patients")),
      body: Column(
        children: [
          const AppHeader(subtitle: "Registered Patients"),
          Expanded(
            child: FutureBuilder(
              future: ApiClient.get('/users'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final res = snapshot.data as dynamic;
                final decoded = jsonDecode(res.body);
                final List patients = decoded['users'];

                if (patients.isEmpty) {
                  return const Center(child: Text("No patients found"));
                }

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (_, i) {
                    final p = patients[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(p['full_name'] ?? '-'),
                        subtitle: Text("📞 ${p['phone']}"),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text("Edit")),
                            PopupMenuItem(
                                value: 'delete', child: Text("Delete")),
                          ],
                          onSelected: (v) {
                            // wire later
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
