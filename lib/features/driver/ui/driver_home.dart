import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'driver_orders_page.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Driver',
      roleLabel: 'driver',
      body: const DriverOrdersPage(),
    );
  }
}
