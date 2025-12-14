import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMenuItemPage extends StatefulWidget {
  final String restaurantId;
  const AddMenuItemPage({super.key, required this.restaurantId});

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  bool isAvailable = true;

  String? error;
  bool loading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      loading = true;
      error = null;
    });

    final name = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim());

    if (name.isEmpty || price == null) {
      setState(() {
        loading = false;
        error = 'Enter a name and a valid price.';
      });
      return;
    }

    try {
      final ref = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menuItems');

      await ref.add({
        'name': name,
        'description': desc,
        'price': price,
        'isAvailable': isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Menu Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            TextField(
              controller: descCtrl,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
            TextField(
              controller: priceCtrl,
              decoration:
                  const InputDecoration(labelText: 'Price (e.g., 9.99)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: isAvailable,
              onChanged: (v) => setState(() => isAvailable = v),
              title: const Text('Available'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: loading ? null : save,
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
