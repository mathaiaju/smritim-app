import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';

class ViewCaregiversScreen extends StatelessWidget {
  const ViewCaregiversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Caregivers"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AppHeader(
            subtitle: 'Registered caregivers in this hospital',
          ),
          Expanded(
            child: FutureBuilder(
              future: ApiClient.get('/caregivers'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Unable to load caregivers'),
                  );
                }

                final response = snapshot.data as dynamic;

                if (response.statusCode != 200) {
                  return const Center(
                    child: Text('Failed to fetch caregivers'),
                  );
                }

                /// ✅ SAFE JSON PARSING
                final decoded = jsonDecode(response.body);
                final List caregivers =
                    decoded is Map ? decoded['caregivers'] ?? [] : [];

                if (caregivers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No caregivers found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: caregivers.length,
                  itemBuilder: (context, index) {
                    final caregiver = caregivers[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.groups),
                        ),
                        title: Text(
                          caregiver['full_name'] ?? '—',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (caregiver['phone'] != null)
                              Text('📞 ${caregiver['phone']}'),
                            if (caregiver['relation'] != null)
                              Text('Relation: ${caregiver['relation']}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // TODO: Edit caregiver
                            }
                            if (value == 'delete') {
                              // TODO: Delete caregiver
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
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
