import 'package:flutter/material.dart';
import '../data.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: StreamBuilder(
        stream: DB.orderStream(orderId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!.data();
          if (data == null) return const Center(child: Text('Order not found'));
          final status = data['status'] ?? 'new';
          final total = (data['total'] ?? 0) as num;
          final items = (data['items'] as List?) ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: $orderId'),
                const SizedBox(height: 8),
                Text('Status: $status', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
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
