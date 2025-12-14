import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('restaurants').snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No restaurants yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final name = (data['name'] ?? '') as String;
            final category = (data['category'] ?? '') as String;
            final eta = data['etaMins'];

            return Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text(category),
                trailing: Text('${eta ?? '--'} min'),
                onTap: () {
                  final rid = docs[i].id;
                  context.go('/customer/restaurant/$rid/menu');
                },
              ),
            );
          },
        );
      },
    );
  }
}
