import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'restaurant_orders_page.dart';

class RestaurantHome extends StatelessWidget {
  const RestaurantHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Restaurant',
      roleLabel: 'restaurant',
      body: const RestaurantOrdersPage(),
    );
  }
}
