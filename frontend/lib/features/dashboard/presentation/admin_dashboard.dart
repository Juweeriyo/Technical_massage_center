import 'package:flutter/material.dart';
import 'dashboard_layout.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: "Admin Dashboard",

      menuItems: const [
        SidebarItemData(
          icon: Icons.dashboard,
          title: "Dashboard",
          route: "/admin-dashboard",
        ),
        SidebarItemData(
          icon: Icons.people,
          title: "Patients",
          route: "/patients",
        ),
        SidebarItemData(
          icon: Icons.calendar_month,
          title: "Appointments",
          route: "/appointments",
        ),

        SidebarItemData(
          icon: Icons.healing,
          title: "Treatments",
          route: "/treatments",
        ),
        SidebarItemData(
          icon: Icons.payment,
          title: "Payments",
          route: "/payments",
        ),
      ],

      child: const AdminStatistics(),
    );
  }
}


class AdminStatistics extends StatelessWidget {
  const AdminStatistics({super.key});

  @override
  Widget build(BuildContext context) {

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,

      children: const [

        DashboardCard(
          title: "Total Patients",
          value: "120",
          icon: Icons.people,
        ),

        DashboardCard(
          title: "Today's Appointments",
          value: "15",
          icon: Icons.calendar_today,
        ),

        DashboardCard(
          title: "Completed Sessions",
          value: "86",
          icon: Icons.check_circle,
        ),

        DashboardCard(
          title: "Income",
          value: "\$2500",
          icon: Icons.attach_money,
        ),

      ],
    );
  }
}


class DashboardCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;


  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 45,
            ),

            const SizedBox(height: 15),

            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

          ],
        ),
      ),
    );
  }
}