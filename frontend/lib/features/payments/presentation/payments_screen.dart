import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_layout.dart';
import 'add_payment_dialog.dart';
import 'receipt_dialog.dart';
import '../data/payments_repository.dart';
import '../providers/payments_provider.dart';
import '../../patients/providers/patients_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: "Payments",
      menuItems: [
        SidebarItemData(icon: Icons.dashboard, title: "Dashboard", route: "/admin-dashboard"),
        SidebarItemData(icon: Icons.people, title: "Patients", route: "/patients"),
        SidebarItemData(icon: Icons.calendar_month, title: "Appointments", route: "/appointments"),
        SidebarItemData(icon: Icons.healing, title: "Treatments", route: "/treatments"),
        SidebarItemData(icon: Icons.payment, title: "Payments", route: "/payments"),
      ],
      child: PaymentTable(),
    );
  }
}

class PaymentTable extends ConsumerStatefulWidget {
  const PaymentTable({super.key});

  @override
  ConsumerState<PaymentTable> createState() => _PaymentTableState();
}

class _PaymentTableState extends ConsumerState<PaymentTable> {
  String _searchQuery = "";
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final patientsAsync = ref.watch(patientsProvider);

    final roleAsync = ref.watch(userRoleProvider);

    if (paymentsAsync.isLoading || patientsAsync.isLoading || roleAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentsAsync.hasError) {
      return Center(child: Text('Error: ${paymentsAsync.error}'));
    }

    final role = roleAsync.value;
    if (role == 'Doctor') {
      return const Center(child: Text('Not Authorized', style: TextStyle(color: Colors.red, fontSize: 24)));
    }

    final isAdmin = role == 'Admin';
    final payments = paymentsAsync.value ?? [];
    final patients = patientsAsync.value ?? [];
    final patientMap = {for (var p in patients) p.id: p};

    final filteredPayments = payments.where((payment) {
      bool matchesStatus = _statusFilter == 'All' || payment.status == _statusFilter;
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final patientName = patientMap[payment.patientId]?.fullName.toLowerCase() ?? "";
        matchesSearch = patientName.contains(_searchQuery.toLowerCase());
      }
      return matchesStatus && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Payments",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (isAdmin)
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddPaymentDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Payment"),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
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
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(),
                ),
                value: _statusFilter,
                items: ['All', 'Paid', 'Partial', 'Unpaid']
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
                  columns: [
                    const DataColumn(label: Text("Patient")),
                    if (isAdmin) const DataColumn(label: Text("Total Bill")),
                    if (isAdmin) const DataColumn(label: Text("Amount Paid")),
                    if (isAdmin) const DataColumn(label: Text("Balance")),
                    const DataColumn(label: Text("Method")),
                    const DataColumn(label: Text("Status")),
                    if (isAdmin) const DataColumn(label: Text("Actions")),
                  ],
                  rows: filteredPayments.map((payment) {
                    final patientName = patientMap[payment.patientId]?.fullName ?? 'Unknown';
                    final balance = (payment.totalAmount ?? 0) - (payment.amountPaid ?? 0);

                    Color statusColor = Colors.red;
                    if (payment.status == 'Paid') statusColor = Colors.green;
                    else if (payment.status == 'Partial') statusColor = Colors.orange;

                    return DataRow(
                      cells: [
                        DataCell(Text(patientName)),
                        if (isAdmin) DataCell(Text('\$${payment.totalAmount?.toStringAsFixed(2) ?? "0.00"}')),
                        if (isAdmin) DataCell(Text('\$${payment.amountPaid?.toStringAsFixed(2) ?? "0.00"}')),
                        if (isAdmin) DataCell(Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(payment.paymentMethod)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              payment.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (isAdmin)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.receipt_long, color: Colors.blue),
                                  tooltip: 'Print Receipt',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ReceiptDialog(payment: payment, patientName: patientName),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  tooltip: 'Edit Payment',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AddPaymentDialog(payment: payment),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Delete Payment',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Payment'),
                                        content: const Text('Are you sure you want to delete this payment?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      try {
                                        await paymentsRepository.deletePayment(payment.id);
                                        ref.invalidate(paymentsProvider);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment deleted successfully')));
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
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