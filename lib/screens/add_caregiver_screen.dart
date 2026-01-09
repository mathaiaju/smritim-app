import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';

class AddCaregiverScreen extends StatefulWidget {
  const AddCaregiverScreen({super.key});

  @override
  State<AddCaregiverScreen> createState() => _AddCaregiverScreenState();
}

class _AddCaregiverScreenState extends State<AddCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _relation = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool submitting = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || submitting) return;

    setState(() => submitting = true);

    try {
      final res = await ApiClient.postJson(
        "/users/onboard/caregiver",
        {
          "full_name": _name.text.trim(),
          "phone": _phone.text.trim(),
          "relation": _relation.text.trim(),
          "username": _username.text.trim(),
          "password": _password.text.trim(),
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Caregiver created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw body['error'] ?? "Failed to create caregiver";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Caregiver")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppHeader(subtitle: "Register caregiver access"),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(_name, "Full name"),
                  _field(_phone, "Phone"),
                  _field(_relation, "Relation"),
                  _field(_username, "Username"),
                  _field(_password, "Password", obscure: true),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submitting ? null : submit,
                    child:
                        Text(submitting ? "Creating..." : "Create Caregiver"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
