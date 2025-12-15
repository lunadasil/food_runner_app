import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data.dart';
import 'menu.dart';

class RestaurantHome extends StatelessWidget {
  const RestaurantHome({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DB.userStream(),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final user = snap.data!.data();
        final restaurantId = user?['restaurantId'] as String?;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Restaurant'),
            actions: [
              IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
            ],
          ),
          body: restaurantId == null
              ? const Center(child: Text('No restaurantId found. Re-pick role as Restaurant.'))
              : Column(
                  children: [
                    ListTile(
                      title: const Text('Manage Menu'),
                      subtitle: Text('Restaurant ID: $restaurantId'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MenuScreen(restaurantId: restaurantId, canEdit: true)),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: StreamBuilder(
                        stream: DB.restaurantOrdersStream(restaurantId),
                        builder: (context, ordersSnap) {
                          if (!ordersSnap.hasData) return const Center(child: CircularProgressIndicator());
                          final docs = ordersSnap.data!.docs;
                          if (docs.isEmpty) return const Center(child: Text('No orders yet.'));
                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (_, i) {
                              final o = docs[i].data();
                              final status = o['status'] ?? 'new';
                              final total = (o['total'] ?? 0) as num;

                              return Card(
                                margin: const EdgeInsets.all(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Order: ${docs[i].id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Status: $status'),
                                      Text('Total: \$${total.toStringAsFixed(2)}'),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => DB.updateOrderStatus(docs[i].id, 'preparing'),
                                            child: const Text('Preparing'),
                                          ),
                                          OutlinedButton(
                                            onPressed: () => DB.updateOrderStatus(docs[i].id, 'ready'),
                                            child: const Text('Ready'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
