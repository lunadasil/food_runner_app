import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver'),
        actions: [
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [
              Tab(text: 'Available'),
              Tab(text: 'My Orders'),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder(
                    stream: DB.readyOrdersStream(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) return const Center(child: Text('No ready orders.'));
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final o = docs[i].data();
                          final total = (o['total'] ?? 0) as num;
                          return ListTile(
                            title: Text('Order: ${docs[i].id}'),
                            subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
                            trailing: FilledButton(
                              onPressed: () => DB.acceptOrder(docs[i].id),
                              child: const Text('Accept'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder(
                    stream: DB.myDriverOrdersStream(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) return const Center(child: Text('No orders assigned yet.'));
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final o = docs[i].data();
                          final status = o['status'] ?? '';
                          return ListTile(
                            title: Text('Order: ${docs[i].id}'),
                            subtitle: Text('Status: $status'),
                            trailing: status == 'picked_up'
                                ? FilledButton(
                                    onPressed: () => DB.deliverOrder(docs[i].id),
                                    child: const Text('Delivered'),
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
