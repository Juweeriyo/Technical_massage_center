import 'package:flutter/material.dart';
import 'dashboard_layout.dart';


class DoctorDashboard extends StatelessWidget {

  const DoctorDashboard({super.key});


  @override
  Widget build(BuildContext context) {

    return DashboardLayout(

      title: "Doctor Dashboard",

      menuItems: const [

        SidebarItemData(
          icon: Icons.dashboard,
          title: "Dashboard",
          route: "/doctor-dashboard",
        ),

        SidebarItemData(
          icon: Icons.people,
          title: "Patients",
          route: "/doctor-patients",
        ),

        SidebarItemData(
          icon: Icons.calendar_month,
          title: "Appointments",
          route: "/doctor-appointments",
        ),


        SidebarItemData(
          icon: Icons.healing,
          title: "Treatment Plans",
          route: "/doctor-treatments",
        ),

      ],


      child: const DoctorStatistics(),

    );

  }

}



class DoctorStatistics extends StatelessWidget {

  const DoctorStatistics({super.key});


  @override
  Widget build(BuildContext context) {

    return GridView.count(

      crossAxisCount: 4,

      crossAxisSpacing: 20,

      mainAxisSpacing: 20,


      children: const [

        DoctorCard(
          title: "Today's Appointments",
          value: "8",
          icon: Icons.calendar_today,
        ),


        DoctorCard(
          title: "My Patients",
          value: "45",
          icon: Icons.people,
        ),


        DoctorCard(
          title: "Active Treatments",
          value: "20",
          icon: Icons.healing,
        ),


        DoctorCard(
          title: "Completed Sessions",
          value: "120",
          icon: Icons.check_circle,
        ),

      ],

    );

  }

}



class DoctorCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;


  const DoctorCard({

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


            Text(title),

          ],

        ),

      ),

    );

  }

}