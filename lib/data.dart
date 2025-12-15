import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DB {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static String get uid => auth.currentUser!.uid;

  // USERS
  static Future<void> ensureUserDoc(String email) async {
    final ref = firestore.collection('users').doc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': email,
        'role': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> setRole(String role) async {
    final userRef = firestore.collection('users').doc(uid);

    if (role == 'restaurant') {
      // Create a restaurant owned by this user if they don't already have one
      final current = await userRef.get();
      final existingRestaurantId = current.data()?['restaurantId'];
      if (existingRestaurantId == null) {
        final restaurantRef = await firestore.collection('restaurants').add({
          'name': 'My Restaurant',
          'ownerId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await userRef.set({
          'role': role,
          'restaurantId': restaurantRef.id,
        }, SetOptions(merge: true));
        return;
      }
    }

    await userRef.set({'role': role}, SetOptions(merge: true));
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return firestore.collection('users').doc(uid).snapshots();
  }

  // RESTAURANTS
  static Stream<QuerySnapshot<Map<String, dynamic>>> restaurantsStream() {
    return firestore.collection('restaurants').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> menuStream(String restaurantId) {
    return firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menuItems')
        .snapshots();
  }

  static Future<void> addMenuItem(String restaurantId, {
    required String name,
    required String description,
    required double price,
  }) async {
    await firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menuItems')
        .add({
          'name': name,
          'description': description,
          'price': price,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> deleteMenuItem(String restaurantId, String itemId) async {
    await firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menuItems')
        .doc(itemId)
        .delete();
  }

  // ORDERS
  static Future<String> placeOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final ref = await firestore.collection('orders').add({
      'customerId': uid,
      'restaurantId': restaurantId,
      'driverId': null,
      'status': 'new',
      'items': items,
      'total': total,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> orderStream(String orderId) {
    return firestore.collection('orders').doc(orderId).snapshots();
  }

  // Restaurant sees only orders for their restaurant (no orderBy, no index)
  static Stream<QuerySnapshot<Map<String, dynamic>>> restaurantOrdersStream(String restaurantId) {
    return firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await firestore.collection('orders').doc(orderId).update({'status': status});
  }

  // Driver
  static Stream<QuerySnapshot<Map<String, dynamic>>> readyOrdersStream() {
    return firestore.collection('orders').where('status', isEqualTo: 'ready').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> myDriverOrdersStream() {
    return firestore.collection('orders').where('driverId', isEqualTo: uid).snapshots();
  }

  static Future<void> acceptOrder(String orderId) async {
    await firestore.collection('orders').doc(orderId).update({
      'driverId': uid,
      'status': 'picked_up',
    });
  }

  static Future<void> deliverOrder(String orderId) async {
    await firestore.collection('orders').doc(orderId).update({'status': 'delivered'});
  }
}
