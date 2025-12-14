import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantOrdersPage extends StatelessWidget {
  const RestaurantOrdersPage({super.key});

  // For now: restaurant selects which restaurant they're managing
  // (Later you can tie restaurant accounts to a restaurantId in users doc)
  static const String restaurantIdForDemo = 'EHIJUMDzX5IV2iiVTTVk';

  @override
  Widget build(BuildContext context) {
    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantIdForDemo)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ordersQuery.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No orders yet.'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            final status = (data['status'] ?? 'new') as String;
            final total = (data['total'] ?? 0) as num;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order: ${doc.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text('Status: $status'),
                    Text('Total: \$${total.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              doc.reference.update({'status': 'preparing'}),
                          child: const Text('Preparing'),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              doc.reference.update({'status': 'ready'}),
                          child: const Text('Ready'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
