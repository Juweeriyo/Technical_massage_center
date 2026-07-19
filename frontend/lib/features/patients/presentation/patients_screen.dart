import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_patient_dialog.dart';
import 'patient_profile_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patients_provider.dart';
import '../data/patients_repository.dart';
import '../../payments/providers/payments_provider.dart';

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
      child: PatientTable(),
    );
  }
}

class PatientTable extends ConsumerStatefulWidget {
  const PatientTable({super.key});

  @override
  ConsumerState<PatientTable> createState() => _PatientTableState();
}

class _PatientTableState extends ConsumerState<PatientTable> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(searchPatientsProvider(_searchQuery));

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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by Phone Number...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const headerHeight = 56.0;
                    const minTableWidth = 780.0;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: minTableWidth),
                        child: SizedBox(
                          width: minTableWidth,
                          child: Column(
                            children: [
                              Container(
                                height: headerHeight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerLeft,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "Name",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Phone",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Age",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Payment Status",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Actions",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: constraints.maxHeight - headerHeight,
                                child: ListView.separated(
                                  itemCount: patients.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 0),
                                  itemBuilder: (context, index) {
                                    final patient = patients[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(patient.fullName),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(patient.phoneNumber),
                                          ),
                                          Expanded(
                                            child: Text(patient.age.toString()),
                                          ),
                                          Expanded(
                                            child: Consumer(
                                              builder: (context, ref, child) {
                                                final statusAsync = ref.watch(patientPaymentStatusProvider(patient.id));
                                                return statusAsync.when(
                                                  loading: () => const Text("..."),
                                                  error: (_, __) => const Text("Error"),
                                                  data: (status) {
                                                    Color statusColor = Colors.red;
                                                    if (status == 'All Paid') statusColor = Colors.green;
                                                    else if (status == 'Partially Paid') statusColor = Colors.orange;
                                                    return Text(
                                                      status,
                                                      style: TextStyle(
                                                        color: statusColor,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.visibility),
                                                  tooltip: 'View Profile',
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => PatientProfileDialog(patient: patient),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          AddPatientDialog(
                                                        patient: patient,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () async {
                                                    final confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Delete Patient"),
                                                          content: Text(
                                                            "Are you sure you want to delete ${patient.fullName}?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context,
                                                                    false);
                                                              },
                                                              child: const Text(
                                                                  "Cancel"),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                              },
                                                              child: const Text(
                                                                  "Delete"),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    if (confirm == true) {
                                                      try {
                                                        await patientsRepository.deletePatient(patient.id);
                                                        ref.invalidate(patientsProvider);
                                                        ref.invalidate(searchPatientsProvider);
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Patient deleted successfully')),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (mounted) {
                                                          String errorMsg = e.toString();
                                                          if (errorMsg.contains('403') || errorMsg.contains('Not authorized')) {
                                                            errorMsg = 'Only administrators can delete patients.';
                                                          }
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(errorMsg),
                                                              backgroundColor: Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
