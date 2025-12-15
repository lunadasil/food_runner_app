import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/role_pick.dart';
import 'screens/customer_home.dart';
import 'screens/restaurant_home.dart';
import 'screens/driver_home.dart';

class AppRouter extends StatelessWidget {
  AppRouter({super.key});

  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _db.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snap.data?.data();
        final role = data?['role'] as String?;

        if (role == null) return const RolePickScreen();

        return switch (role) {
          'customer' => const CustomerHome(),
          'restaurant' => const RestaurantHome(),
          'driver' => const DriverHome(),
          _ => const RolePickScreen(),
        };
      },
    );
  }
}
