import 'package:flutter/material.dart';
import '../../api_client.dart';

class AddPvpiCaseScreen extends StatefulWidget {
  final Map<String, String>? prefill;
  const AddPvpiCaseScreen({super.key, this.prefill});

  @override
  State<AddPvpiCaseScreen> createState() => _AddPvpiCaseScreenState();
}

class _AddPvpiCaseScreenState extends State<AddPvpiCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool submitting = false;
  String? error;
  String? success;

  // List your required fields here (excluding the ones you said are not required)
  final List<Map<String, String>> fields = [
    {"key": "adr_description", "label": "ADR Description"},
    {"key": "suspected_drug", "label": "Suspected Drug(s)"},
    {"key": "reaction_outcome", "label": "Reaction Outcome"},
    {"key": "seriousness", "label": "Seriousness (Yes/No)"},
    {"key": "reporter_name", "label": "Reporter Name"},
    {"key": "reporter_contact", "label": "Reporter Contact"},
    {"key": "hospital_name", "label": "Hospital Name"},
    {"key": "action_taken", "label": "Action Taken for ADR"},
    // Add more fields as per your ADR form screenshot, except the excluded ones
  ];

  @override
  void initState() {
    super.initState();
    for (final field in fields) {
      final key = field["key"]!;
      _controllers[key] = TextEditingController(
        text: widget.prefill != null && widget.prefill![key] != null
            ? widget.prefill![key]
            : '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      submitting = true;
      error = null;
      success = null;
    });
    final data = {
      for (final f in fields) f["key"]!: _controllers[f["key"]!]!.text.trim()
    };
    // Get alert_id from route arguments
    final alertId = ModalRoute.of(context)?.settings.arguments;
    if (alertId != null) {
      data['alert_id'] = alertId.toString();
    }
    try {
      final res = await ApiClient.postJson('/pvpi/from-alert', data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() => success = "PvPI case created successfully.");
        Navigator.of(context).pop(true); // Return success to previous screen
      } else {
        setState(
            () => error = "Failed to create PvPI case. (\u007f{res.statusCode})");
      }
    } catch (e) {
      setState(() => error = "Error: $e");
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create PvPI Case')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...fields.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: _controllers[f["key"]!],
                      decoration: InputDecoration(
                        labelText: f["label"],
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  )),
              const SizedBox(height: 24),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              if (success != null)
                Text(success!, style: const TextStyle(color: Colors.green)),
              ElevatedButton(
                onPressed: submitting ? null : _submit,
                child: submitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
