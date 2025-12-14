import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data?.data();
          if (data == null) {
            return const Center(child: Text('Order not found.'));
          }

          final status = (data['status'] ?? 'new') as String;
          final total = (data['total'] ?? 0) as num;
          final items = (data['items'] as List?) ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: $orderId'),
                const SizedBox(height: 8),
                Text(
                  'Status: $status',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final it = items[i] as Map;
                      return ListTile(
                        title: Text('${it['name']}'),
                        subtitle: Text('Qty: ${it['qty']}'),
                        trailing: Text('\$${it['price']}'),
                      );
                    },
                  ),
                ),
                const Divider(),
                Text('Total: \$${total.toStringAsFixed(2)}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
