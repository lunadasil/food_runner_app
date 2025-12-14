import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/ui/auth_gate.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';

import 'features/customer/ui/customer_home.dart';
import 'features/restaurant/ui/restaurant_home.dart';
import 'features/driver/ui/driver_home.dart';

import 'features/menus/ui/menu_page.dart';

class FoodRunnerApp extends StatelessWidget {
  const FoodRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const AuthGate()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

        GoRoute(path: '/customer', builder: (_, __) => const CustomerHome()),
        GoRoute(path: '/restaurant', builder: (_, __) => const RestaurantHome()),
        GoRoute(path: '/driver', builder: (_, __) => const DriverHome()),

        // CUSTOMER: View Menu (read-only)
        GoRoute(
          path: '/customer/restaurant/:rid/menu',
          builder: (_, state) => MenuPage(
            restaurantId: state.pathParameters['rid']!,
            canEdit: false,
          ),
        ),

        // RESTAURANT: Manage Menu (CRUD)
        GoRoute(
          path: '/restaurant/restaurant/:rid/menu',
          builder: (_, state) => MenuPage(
            restaurantId: state.pathParameters['rid']!,
            canEdit: true,
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'The Food Runner',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}
