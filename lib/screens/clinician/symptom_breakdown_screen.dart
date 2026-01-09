import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';

class SymptomBreakdownScreen extends StatefulWidget {
  final int patientId;

  const SymptomBreakdownScreen({super.key, required this.patientId});

  @override
  State<SymptomBreakdownScreen> createState() => _SymptomBreakdownScreenState();
}

class _SymptomBreakdownScreenState extends State<SymptomBreakdownScreen> {
  bool loading = true;
  List<Map<String, dynamic>> symptoms = [];

  @override
  void initState() {
    super.initState();
    loadSymptoms();
  }

  Future<void> loadSymptoms() async {
    try {
      final res = await ApiClient.get(
        '/clinicians/patient/${widget.patientId}/top-symptoms',
      );
      setState(() {
        symptoms = List<Map<String, dynamic>>.from(
          jsonDecode(res.body)['symptoms'] ?? [],
        );
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Breakdown'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : symptoms.isEmpty
              ? const Center(child: Text('No symptoms reported'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: symptoms.length,
                  itemBuilder: (_, i) {
                    final s = symptoms[i];
                    return Card(
                      child: ListTile(
                        title: Text(s['name']),
                        trailing: Text(
                          s['count'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
