import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnap.data;
        if (user == null) {
          // Not logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        // Logged in: read role from Firestore
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final data = roleSnap.data?.data();
            final role = data?['role'] as String?;

            if (role == null) {
              // user exists in Auth but no profile doc yet -> go register/finish profile
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/register');
              });
              return const Scaffold(body: SizedBox.shrink());
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (role == 'customer') context.go('/customer');
              else if (role == 'restaurant') context.go('/restaurant');
              else if (role == 'driver') context.go('/driver');
              else context.go('/register'); // unknown role fallback
            });

            return const Scaffold(body: SizedBox.shrink());
          },
        );
      },
    );
  }
}
