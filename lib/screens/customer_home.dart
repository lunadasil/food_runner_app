import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data.dart';
import 'menu.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
        actions: [
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder(
        stream: DB.restaurantsStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No restaurants yet (create one as Restaurant role).'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final r = docs[i].data();
              return ListTile(
                title: Text(r['name'] ?? 'Restaurant'),
                subtitle: Text('ID: ${docs[i].id}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuScreen(restaurantId: docs[i].id, canEdit: false),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
