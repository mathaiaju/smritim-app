import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';

class AddClinicianScreen extends StatefulWidget {
  const AddClinicianScreen({super.key});

  @override
  State<AddClinicianScreen> createState() => _AddClinicianScreenState();
}

class _AddClinicianScreenState extends State<AddClinicianScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool submitting = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || submitting) return;

    setState(() => submitting = true);

    try {
      final res = await ApiClient.postJson(
        "/users/onboard/clinician",
        {
          "full_name": _name.text.trim(),
          "email": _email.text.trim(),
          "phone": _phone.text.trim(),
          "username": _username.text.trim(),
          "password": _password.text.trim(),
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Clinician created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw body['error'] ?? "Failed to create clinician";
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
      appBar: AppBar(title: const Text("Add Clinician")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppHeader(subtitle: "Register clinician access"),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(_name, "Full name"),
                  _field(_email, "Email"),
                  _field(_phone, "Phone"),
                  _field(_username, "Username"),
                  _field(_password, "Password", obscure: true),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submitting ? null : submit,
                    child:
                        Text(submitting ? "Creating..." : "Create Clinician"),
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
