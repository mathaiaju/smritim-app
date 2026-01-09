import 'package:flutter/material.dart';

class UserListScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final Widget body;

  const UserListScaffold({
    super.key,
    required this.title,
    required this.onAdd,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
      body: body,
    );
  }
}
