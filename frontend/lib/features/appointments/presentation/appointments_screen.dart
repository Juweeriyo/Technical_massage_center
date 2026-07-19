import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_appointment_dialog.dart';
import '../providers/appointments_provider.dart';
import '../data/appointments_repository.dart';
import '../../patients/providers/patients_provider.dart';
import '../../auth/providers/doctors_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: "Appointments",
      menuItems: [
        SidebarItemData(icon: Icons.dashboard, title: "Dashboard", route: "/admin-dashboard"),
        SidebarItemData(icon: Icons.people, title: "Patients", route: "/patients"),
        SidebarItemData(icon: Icons.calendar_month, title: "Appointments", route: "/appointments"),
        SidebarItemData(icon: Icons.healing, title: "Treatments", route: "/treatments"),
        SidebarItemData(icon: Icons.payment, title: "Payments", route: "/payments"),
      ],
      child: AppointmentTable(),
    );
  }
}

class AppointmentTable extends ConsumerStatefulWidget {
  const AppointmentTable({super.key});

  @override
  ConsumerState<AppointmentTable> createState() => _AppointmentTableState();
}

class _AppointmentTableState extends ConsumerState<AppointmentTable> {
  String _searchQuery = "";
  int? _selectedDoctorId;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final patientsAsync = ref.watch(patientsProvider);
    final doctorsAsync = ref.watch(doctorsProvider);
    final roleAsync = ref.watch(userRoleProvider);

    if (appointmentsAsync.isLoading || patientsAsync.isLoading || doctorsAsync.isLoading || roleAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointmentsAsync.hasError) {
      return Center(child: Text('Error: ${appointmentsAsync.error}'));
    }

    final role = roleAsync.value;
    final isAdmin = role == 'Admin';
    final isDoctor = role == 'Doctor';
    final isStaff = role == 'Staff';

    final appointments = appointmentsAsync.value ?? [];
    final patients = patientsAsync.value ?? [];
    final doctors = doctorsAsync.value ?? [];

    // Map for quick lookups
    final patientMap = {for (var p in patients) p.id: p};
    final doctorMap = {for (var d in doctors) d.id: d};

    // Filter appointments
    var filteredAppointments = appointments.where((appt) {
      bool matchesDoctor = _selectedDoctorId == null || appt.doctorId == _selectedDoctorId;
      bool matchesDate = true;
      if (_selectedDate != null) {
        final apptDate = DateTime.tryParse(appt.date);
        if (apptDate != null) {
          matchesDate = apptDate.year == _selectedDate!.year &&
              apptDate.month == _selectedDate!.month &&
              apptDate.day == _selectedDate!.day;
        }
      }
      
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final patientName = patientMap[appt.patientId]?.fullName.toLowerCase() ?? "";
        matchesSearch = patientName.contains(_searchQuery.toLowerCase());
      }
      
      return matchesDoctor && matchesDate && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Appointments",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (isAdmin)
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddAppointmentDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Book Appointment"),
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
            if (isAdmin || isStaff)
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
              )
            else
              const Spacer(),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null 
                        ? "All Dates" 
                        : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                  ),
                ),
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _selectedDate = null),
              ),
          ],
        ),
        const SizedBox(height: 25),
        Expanded(
          child: Card(
            child: ListView(
              children: [
                DataTable(
                  columns: [
                    const DataColumn(label: Text("Patient")),
                    const DataColumn(label: Text("Doctor")),
                    const DataColumn(label: Text("Date")),
                    const DataColumn(label: Text("Time")),
                    const DataColumn(label: Text("Status")),
                    if (isAdmin || isDoctor) const DataColumn(label: Text("Actions")),
                  ],
                  rows: filteredAppointments.map((appt) {
                    final patientName = patientMap[appt.patientId]?.fullName ?? 'Unknown';
                    final doctorName = doctorMap[appt.doctorId]?.username ?? 'Unknown';
                    
                    Color statusColor = Colors.grey;
                    if (appt.status == 'Scheduled') statusColor = Colors.blue;
                    if (appt.status == 'Completed') statusColor = Colors.green;
                    if (appt.status == 'Cancelled') statusColor = Colors.red;

                    return DataRow(
                      cells: [
                        DataCell(Text(patientName)),
                        DataCell(Text(doctorName)),
                        DataCell(Text(appt.date)),
                        DataCell(Text(appt.time)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appt.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (isAdmin || isDoctor)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(isDoctor ? Icons.update : Icons.edit, color: Colors.blue),
                                  tooltip: isDoctor ? 'Update Status' : 'Edit',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AddAppointmentDialog(appointment: appt),
                                    );
                                  },
                                ),
                                if (isAdmin && appt.status != 'Cancelled')
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.orange),
                                    tooltip: 'Cancel Appointment',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Cancel Appointment'),
                                          content: const Text('Are you sure you want to cancel this appointment?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                              onPressed: () => Navigator.pop(ctx, true), 
                                              child: const Text('Yes')
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await appointmentsRepository.cancelAppointment(appt.id);
                                          ref.invalidate(appointmentsProvider);
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      }
                                    },
                                  ),
                                if (isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Delete Appointment',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Appointment'),
                                          content: const Text('Are you sure you want to completely delete this appointment?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(ctx, true), 
                                              child: const Text('Delete')
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await appointmentsRepository.deleteAppointment(appt.id);
                                          ref.invalidate(appointmentsProvider);
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      }
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