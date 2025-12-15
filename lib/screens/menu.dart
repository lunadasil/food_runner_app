import 'package:flutter/material.dart';
import '../data.dart';
import 'order_tracking.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantId;
  final bool canEdit;
  const MenuScreen({super.key, required this.restaurantId, required this.canEdit});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final cart = <Map<String, dynamic>>[]; // {itemId,name,price,qty}
  double get total => cart.fold(0.0, (sum, it) => sum + (it['price'] as num).toDouble() * (it['qty'] as int));

  void addToCart(String itemId, String name, double price) {
    setState(() {
      final idx = cart.indexWhere((e) => e['itemId'] == itemId);
      if (idx >= 0) {
        cart[idx]['qty'] = (cart[idx]['qty'] as int) + 1;
      } else {
        cart.add({'itemId': itemId, 'name': name, 'price': price, 'qty': 1});
      }
    });
  }

  Future<void> placeOrder() async {
    if (cart.isEmpty) return;
    final items = cart.map((e) => {
      'itemId': e['itemId'],
      'name': e['name'],
      'price': e['price'],
      'qty': e['qty'],
    }).toList();

    final orderId = await DB.placeOrder(
      restaurantId: widget.restaurantId,
      items: items,
      total: total,
    );

    setState(() => cart.clear());

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
    );
  }

  Future<void> addMenuItemDialog() async {
    final name = TextEditingController();
    final desc = TextEditingController();
    final price = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok == true) {
      final p = double.tryParse(price.text.trim()) ?? 0;
      await DB.addMenuItem(widget.restaurantId, name: name.text.trim(), description: desc.text.trim(), price: p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.canEdit ? 'Manage Menu' : 'Menu';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton(
              onPressed: addMenuItemDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder(
        stream: DB.menuStream(widget.restaurantId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No menu items yet.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final m = docs[i].data();
              final itemId = docs[i].id;
              final name = (m['name'] ?? 'Item') as String;
              final price = (m['price'] ?? 0) as num;

              return ListTile(
                title: Text(name),
                subtitle: Text(m['description'] ?? ''),
                trailing: widget.canEdit
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => DB.deleteMenuItem(widget.restaurantId, itemId),
                      )
                    : Text('\$${price.toStringAsFixed(2)}'),
                onTap: widget.canEdit
                    ? null
                    : () => addToCart(itemId, name, price.toDouble()),
              );
            },
          );
        },
      ),
      bottomNavigationBar: widget.canEdit
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: Text('Cart: ${cart.length} items • Total: \$${total.toStringAsFixed(2)}')),
                    FilledButton(
                      onPressed: cart.isEmpty ? null : placeOrder,
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
