import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverOrdersPage extends StatelessWidget {
  const DriverOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final readyOrders = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .orderBy('createdAt', descending: true);

    final myOrders = FirebaseFirestore.instance
        .collection('orders')
        .where('driverId', isEqualTo: user?.uid ?? 'no-user')
        .orderBy('createdAt', descending: true);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Available (Ready)'),
              Tab(text: 'My Orders'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OrdersList(
                  query: readyOrders,
                  emptyText: 'No ready orders yet.',
                  actionsBuilder: (doc, data) {
                    return [
                      FilledButton(
                        onPressed: user == null
                            ? null
                            : () async {
                                await doc.reference.update({
                                  'driverId': user.uid,
                                  'status': 'picked_up',
                                });
                              },
                        child: const Text('Accept'),
                      ),
                    ];
                  },
                ),
                _OrdersList(
                  query: myOrders,
                  emptyText: 'No orders assigned to you yet.',
                  actionsBuilder: (doc, data) {
                    final status = (data['status'] ?? '') as String;
                    return [
                      if (status == 'picked_up')
                        FilledButton(
                          onPressed: () async {
                            await doc.reference.update({'status': 'delivered'});
                          },
                          child: const Text('Mark Delivered'),
                        )
                      else
                        OutlinedButton(
                          onPressed: null,
                          child: Text('Status: $status'),
                        ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final Query<Map<String, dynamic>> query;
  final String emptyText;
  final List<Widget> Function(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) actionsBuilder;

  const _OrdersList({
    required this.query,
    required this.emptyText,
    required this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text(emptyText));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            final status = (data['status'] ?? '') as String;
            final total = (data['total'] ?? 0) as num;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order: ${doc.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Status: $status'),
                    Text('Total: \$${total.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, children: actionsBuilder(doc, data)),
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
