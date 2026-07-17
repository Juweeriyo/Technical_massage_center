import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_treatment_dialog.dart';

class TreatmentsScreen extends StatelessWidget {

  const TreatmentsScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return DashboardLayout(

      title: "Treatments",

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


      child: const TreatmentTable(),

    );
  }
}



class TreatmentTable extends StatelessWidget {

  const TreatmentTable({super.key});


  @override
  Widget build(BuildContext context) {


    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,


      children: [

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            const Text(
              "Treatment Plans",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),


           ElevatedButton.icon(

              onPressed: () {

                showDialog(
                  context: context,
                  builder: (_) => const AddTreatmentDialog(),
                );
                

              },

              icon: const Icon(Icons.add),

              label: const Text(
                "Create Treatment",
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
                  label: Text("Massage Mode"),
                ),

                DataColumn(
                  label: Text("Sessions"),
                ),

                DataColumn(
                  label: Text("Completed"),
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
                      Text("Deep Tissue Massage"),
                    ),

                    DataCell(
                      Text("10"),
                    ),

                    DataCell(
                      Text("4"),
                    ),

                    DataCell(
                      Text("Active"),
                    ),

                  ],

                ),



                DataRow(

                  cells: [

                    DataCell(
                      Text("Fatima Hassan"),
                    ),

                    DataCell(
                      Text("Relaxation Massage"),
                    ),

                    DataCell(
                      Text("8"),
                    ),

                    DataCell(
                      Text("8"),
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