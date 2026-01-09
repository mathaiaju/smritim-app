import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';

class ViewAdminsScreen extends StatelessWidget {
  const ViewAdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Admins")),
      body: Column(
        children: [
          const AppHeader(subtitle: "Administrative Users"),
          Expanded(
            child: FutureBuilder(
              future: ApiClient.get('/auth/admins'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final res = snapshot.data as dynamic;
                final decoded = jsonDecode(res.body);
                final List admins = decoded['admins'];

                if (admins.isEmpty) {
                  return const Center(child: Text("No admins found"));
                }

                return ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (_, i) {
                    final a = admins[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: Text(a['username']),
                        subtitle: Text("Created: ${a['created_at']}"),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'reset', child: Text("Reset Password")),
                            PopupMenuItem(
                                value: 'disable', child: Text("Disable")),
                          ],
                          onSelected: (v) {
                            // hook later
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
