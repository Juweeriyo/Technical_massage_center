import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_appointment_dialog.dart';


class AppointmentsScreen extends StatelessWidget {

  const AppointmentsScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return DashboardLayout(

      title: "Appointments",

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
          icon: Icons.medical_services,
          title: "Diagnosis",
          route: "/diagnoses",
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


      child: const AppointmentTable(),

    );
  }
}



class AppointmentTable extends StatelessWidget {

  const AppointmentTable({super.key});


  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,


      children: [

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            const Text(
              "Appointments",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),


            ElevatedButton.icon(

              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddAppointmentDialog(),
                );

              },

              icon: const Icon(Icons.add),

              label: const Text(
                "Book Appointment",
              ),

            ),

          ],

        ),


        const SizedBox(height: 25),



        Expanded(

          child: Card(

            child: DataTable(

              columns: const [

                DataColumn(
                  label: Text("Patient"),
                ),

                DataColumn(
                  label: Text("Doctor"),
                ),

                DataColumn(
                  label: Text("Date"),
                ),

                DataColumn(
                  label: Text("Time"),
                ),

                DataColumn(
                  label: Text("Status"),
                ),

              ],



              rows: const [

                DataRow(

                  cells: [

                    DataCell(
                      Text("Ahmed Ali"),
                    ),

                    DataCell(
                      Text("Dr. Mohamed"),
                    ),

                    DataCell(
                      Text("15/07/2026"),
                    ),

                    DataCell(
                      Text("10:00 AM"),
                    ),

                    DataCell(
                      Text("Pending"),
                    ),

                  ],

                ),



                DataRow(

                  cells: [

                    DataCell(
                      Text("Fatima Hassan"),
                    ),

                    DataCell(
                      Text("Dr. Amina"),
                    ),

                    DataCell(
                      Text("15/07/2026"),
                    ),

                    DataCell(
                      Text("2:00 PM"),
                    ),

                    DataCell(
                      Text("Completed"),
                    ),

                  ],

                ),

              ],

            ),

          ),

        ),

      ],

    );

  }

}