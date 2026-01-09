import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/app_header.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      final res = await ApiClient.postJson(
        '/users/onboard/patient',
        {
          "full_name": name.text.trim(),
          "phone": phone.text.trim(),
          "username": username.text.trim(),
          "password": password.text.trim(),
        },
      );

      setState(() => loading = false);

      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        final msg = jsonDecode(res.body)['error'] ?? 'Failed to create patient';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AppHeader(
                subtitle: 'Register New Patient',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) =>
                    v == null || v.length < 10 ? 'Valid phone required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Username required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Temporary Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 chars required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
