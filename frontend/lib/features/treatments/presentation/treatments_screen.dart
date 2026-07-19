import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import '../../patients/providers/patients_provider.dart';
import '../../auth/providers/doctors_provider.dart';
import 'add_treatment_dialog.dart';
import 'treatment_history_dialog.dart';
import '../providers/treatments_provider.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: "Treatments",
      menuItems: [
        SidebarItemData(icon: Icons.dashboard, title: "Dashboard", route: "/admin-dashboard"),
        SidebarItemData(icon: Icons.people, title: "Patients", route: "/patients"),
        SidebarItemData(icon: Icons.calendar_month, title: "Appointments", route: "/appointments"),
        SidebarItemData(icon: Icons.healing, title: "Treatments", route: "/treatments"),
        SidebarItemData(icon: Icons.payment, title: "Payments", route: "/payments"),
      ],
      child: TreatmentTable(),
    );
  }
}

class TreatmentTable extends ConsumerStatefulWidget {
  const TreatmentTable({super.key});

  @override
  ConsumerState<TreatmentTable> createState() => _TreatmentTableState();
}

class _TreatmentTableState extends ConsumerState<TreatmentTable> {
  String _searchQuery = "";
  int? _selectedDoctorId;
  String _statusFilter = 'All'; // All, Active, Completed

  @override
  Widget build(BuildContext context) {
    final treatmentsAsync = ref.watch(treatmentsProvider);
    final patientsAsync = ref.watch(patientsProvider);
    final doctorsAsync = ref.watch(doctorsProvider);

    if (treatmentsAsync.isLoading || patientsAsync.isLoading || doctorsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (treatmentsAsync.hasError) {
      return Center(child: Text('Error: ${treatmentsAsync.error}'));
    }

    final treatments = treatmentsAsync.value ?? [];
    final patients = patientsAsync.value ?? [];
    final doctors = doctorsAsync.value ?? [];

    final patientMap = {for (var p in patients) p.id: p};
    final doctorMap = {for (var d in doctors) d.id: d};

    // Filter treatments
    final filteredTreatments = treatments.where((treatment) {
      bool matchesDoctor = _selectedDoctorId == null || treatment.doctorId == _selectedDoctorId;
      bool matchesStatus = _statusFilter == 'All' || treatment.status == _statusFilter;
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final patientName = patientMap[treatment.patientId]?.fullName.toLowerCase() ?? "";
        matchesSearch = patientName.contains(_searchQuery.toLowerCase());
      }
      return matchesDoctor && matchesStatus && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Treatment Plans",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddTreatmentDialog(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Create Treatment"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Filters Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by Patient Name...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Doctor',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDoctorId,
                items: [
                  const DropdownMenuItem(value: null, child: Text("All Doctors")),
                  ...doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.username)))
                ],
                onChanged: (val) => setState(() => _selectedDoctorId = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(),
                ),
                value: _statusFilter,
                items: ['All', 'Active', 'Completed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _statusFilter = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Expanded(
          child: Card(
            child: ListView(
              children: [
                DataTable(
                  columns: const [
                    DataColumn(label: Text("Patient")),
                    DataColumn(label: Text("Doctor")),
                    DataColumn(label: Text("Massage Mode")),
                    DataColumn(label: Text("Sessions")),
                    DataColumn(label: Text("Started")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: filteredTreatments.map((treatment) {
                    final patientName = patientMap[treatment.patientId]?.fullName ?? 'Unknown';
                    final doctorName = doctorMap[treatment.doctorId]?.username ?? 'Unknown';

                    Color statusColor = Colors.blue;
                    if (treatment.status == 'Completed') statusColor = Colors.green;

                    return DataRow(
                      cells: [
                        DataCell(Text(patientName)),
                        DataCell(Text(doctorName)),
                        DataCell(Text('Mode ${treatment.mode}')),
                        DataCell(Text('${treatment.numberOfSessions}')),
                        DataCell(Text(treatment.startDate)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              treatment.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.history, color: Colors.blue),
                                tooltip: 'View History & Session Notes',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => TreatmentHistoryDialog(treatment: treatment),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                tooltip: 'Edit Treatment',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddTreatmentDialog(treatment: treatment),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
