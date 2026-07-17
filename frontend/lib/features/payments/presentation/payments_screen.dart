import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_payment_dialog.dart';


class PaymentsScreen extends StatelessWidget {

  const PaymentsScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return DashboardLayout(

      title: "Payments",

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


      child: const PaymentTable(),

    );
  }
}



class PaymentTable extends StatelessWidget {

  const PaymentTable({super.key});


  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,


      children: [

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            const Text(
              "Payments",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),


            ElevatedButton.icon(

              onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddPaymentDialog(),
                  );
              },

              icon: const Icon(Icons.add),

              label: const Text(
                "Add Payment",
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
                  label: Text("Treatment"),
                ),

                DataColumn(
                  label: Text("Amount"),
                ),

                DataColumn(
                  label: Text("Date"),
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
                      Text("\$200"),
                    ),

                    DataCell(
                      Text("15/07/2026"),
                    ),

                    DataCell(
                      Text("Paid"),
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
                      Text("\$150"),
                    ),

                    DataCell(
                      Text("14/07/2026"),
                    ),

                    DataCell(
                      Text("Pending"),
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