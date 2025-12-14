import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'restaurant_list_page.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Customer',
      roleLabel: 'customer',
      body: RestaurantListPage(),
    );
  }
}
