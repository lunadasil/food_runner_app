import 'package:flutter/material.dart';
import '../data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RolePickScreen extends StatelessWidget {
  const RolePickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a role'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Choose which experience to use:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => DB.setRole('customer'),
              child: const Text('Customer'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => DB.setRole('restaurant'),
              child: const Text('Restaurant'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => DB.setRole('driver'),
              child: const Text('Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
