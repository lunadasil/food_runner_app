import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_menu_item_page.dart';
import 'package:food_runner/features/orders/ui/order_tracking_page.dart';

class MenuPage extends StatefulWidget {
  final String restaurantId;
  final bool canEdit;

  const MenuPage({
    super.key,
    required this.restaurantId,
    required this.canEdit,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Map<String, Map<String, dynamic>> cart = {}; // key=itemId

  double get total {
    double sum = 0;
    for (final item in cart.values) {
      sum += (item['price'] as num).toDouble() * (item['qty'] as int);
    }
    return sum;
  }

  void addToCart(String itemId, Map<String, dynamic> data) {
    setState(() {
      if (cart.containsKey(itemId)) {
        cart[itemId]!['qty'] = (cart[itemId]!['qty'] as int) + 1;
      } else {
        cart[itemId] = {
          'name': data['name'],
          'price': (data['price'] as num).toDouble(),
          'qty': 1,
        };
      }
    });
  }

  void removeFromCart(String itemId) {
    setState(() {
      if (!cart.containsKey(itemId)) return;
      final q = cart[itemId]!['qty'] as int;
      if (q <= 1)
        cart.remove(itemId);
      else
        cart[itemId]!['qty'] = q - 1;
    });
  }

  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final items = cart.values
        .map((e) => {'name': e['name'], 'price': e['price'], 'qty': e['qty']})
        .toList();

    final orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'customerId': user.uid,
      'restaurantId': widget.restaurantId,
      'status': 'new',
      'items': items,
      'total': total,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    setState(() => cart.clear());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(orderId: orderRef.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('menuItems');

    return Scaffold(
      appBar: AppBar(title: Text(widget.canEdit ? 'Manage Menu' : 'Menu')),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddMenuItemPage(restaurantId: widget.restaurantId),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: menuRef.orderBy('name').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      widget.canEdit
                          ? 'No items yet. Tap + to add one.'
                          : 'No menu items yet.',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final name = (data['name'] ?? '') as String;
                    final price = (data['price'] ?? 0) as num;
                    final available = (data['isAvailable'] ?? true) as bool;
                    final itemId = doc.id;

                    return Card(
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text(available ? 'Available' : 'Unavailable'),
                        trailing: Text('\$${price.toStringAsFixed(2)}'),
                        onTap: widget.canEdit
                            ? null
                            : () => addToCart(itemId, data),
                        onLongPress: widget.canEdit
                            ? () async => await doc.reference.delete()
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // CUSTOMER CART (only show if canEdit == false)
          if (!widget.canEdit)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: const Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cart: ${cart.isEmpty ? "empty" : "${cart.length} items"}',
                  ),
                  const SizedBox(height: 6),
                  if (cart.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cart.entries.map((e) {
                        final id = e.key;
                        final item = e.value;
                        return Chip(
                          label: Text('${item['name']} x${item['qty']}'),
                          onDeleted: () => removeFromCart(id),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: cart.isEmpty ? null : placeOrder,
                    child: Text('Place order • \$${total.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
