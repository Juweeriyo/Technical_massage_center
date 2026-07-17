import 'package:flutter/material.dart';
import 'dashboard_layout.dart';

class StaffDashboard extends StatelessWidget {

  const StaffDashboard({super.key});


  @override
  Widget build(BuildContext context) {

    return const DashboardLayout(
      title: "Staff Dashboard",

      menuItems: const [],

      child: const Center(
        child: Text(
          "Staff Content",
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}