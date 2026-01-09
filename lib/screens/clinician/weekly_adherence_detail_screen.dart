import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api_client.dart';

class WeeklyAdherenceDetailScreen extends StatefulWidget {
  final Map patient;

  const WeeklyAdherenceDetailScreen({super.key, required this.patient});

  @override
  State<WeeklyAdherenceDetailScreen> createState() =>
      _WeeklyAdherenceDetailScreenState();
}

class _WeeklyAdherenceDetailScreenState
    extends State<WeeklyAdherenceDetailScreen> {
  bool loading = true;
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final res = await ApiClient.get(
        '/clinicians/patient/${widget.patient['id']}/adherence-details',
      );
      setState(() {
        logs = List<Map<String, dynamic>>.from(
          jsonDecode(res.body)['logs'] ?? [],
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
        title: const Text('Weekly Adherence Details'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(child: Text('No adherence data available'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final log = logs[i];
                    return ListTile(
                      leading: Icon(
                        log['status'] == 'taken'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: log['status'] == 'taken'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(log['medication']),
                      subtitle: Text(log['date']),
                      trailing: Text(log['status']),
                    );
                  },
                ),
    );
  }
}
