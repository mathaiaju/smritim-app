import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';
import 'alert_details_screen.dart';

class AlertsScreen extends StatelessWidget {
  /// ✅ Default = admin alerts
  /// Clinician can pass '/clinicians/alerts'
  final String apiPath;

  const AlertsScreen({
    super.key,
    this.apiPath = '/alerts',
  });

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'moderate':
        return Colors.amber.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.local_hospital;
      case 'high':
        return Icons.warning_amber_rounded;
      case 'moderate':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: FutureBuilder(
        future: ApiClient.get(apiPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load alerts'));
          }

          final res = snapshot.data as dynamic;

          if (res.statusCode != 200) {
            return const Center(child: Text('Failed to fetch alerts'));
          }

          final decoded = jsonDecode(res.body);

          /// ✅ Works for both:
          /// { alerts: [...] } OR [...]
          final List alerts =
              decoded is List ? decoded : decoded['alerts'] ?? [];

          if (alerts.isEmpty) {
            return const Center(
              child: Text(
                '🎉 No active alerts',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              const AppHeader(
                subtitle: 'Patient Safety & Adherence Alerts',
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: alerts.length,
                  itemBuilder: (context, i) {
                    final alert = alerts[i];
                    final severity = alert['severity'] ?? 'low';

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlertDetailsScreen(alert: alert),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: _severityColor(severity),
                          child: Icon(
                            _severityIcon(severity),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          alert['description'] ?? 'Alert',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Chip(
                              label: Text(
                                severity.toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _severityColor(severity),
                              visualDensity: VisualDensity.compact,
                            ),
                            if (alert['created_at'] != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '🕒 ${alert['created_at']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        trailing: alert['resolved'] == true
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
