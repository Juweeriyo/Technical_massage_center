import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_patient_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patients_provider.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: "Patients",
      menuItems: [
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
      child: const PatientTable(),
    );
  }
}

class PatientTable extends ConsumerWidget {
  const PatientTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);

    return patientsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (patients) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Patients List",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddPatientDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Patient"),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Phone")),
                      DataColumn(label: Text("Age")),
                      DataColumn(label: Text("Status")),
                      DataColumn( label: Text("Actions"),),
                    ],
                    rows: patients.map((patient) {
                      return DataRow(
                        cells: [
                          DataCell(Text(patient.fullName)),
                          DataCell(Text(patient.phoneNumber)),
                          DataCell(Text(patient.age.toString())),
                          const DataCell(Text("Active")),
                          DataCell(
                            Row(
                              children: [

                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {

                                  },
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {

                                  },
                                ),

                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
