import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/payment_model.dart';
import '../data/payments_repository.dart';
import '../providers/payments_provider.dart';
import '../../patients/providers/patients_provider.dart';
import '../../patients/data/patient_model.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final Payment? payment;

  const AddPaymentDialog({super.key, this.payment});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _amountPaidController = TextEditingController();
  String _paymentMethod = 'Cash';
  String _status = 'Unpaid';
  Patient? _selectedPatient;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _totalAmountController.text = (widget.payment!.totalAmount ?? 0.0).toString();
      _amountPaidController.text = (widget.payment!.amountPaid ?? 0.0).toString();
      _paymentMethod = widget.payment!.paymentMethod;
      _status = widget.payment!.status;
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  void _calculateStatus() {
    if (_totalAmountController.text.isEmpty || _amountPaidController.text.isEmpty) return;
    
    double total = double.tryParse(_totalAmountController.text) ?? 0;
    double paid = double.tryParse(_amountPaidController.text) ?? 0;

    setState(() {
      if (paid >= total && total > 0) {
        _status = 'Paid';
      } else if (paid > 0 && paid < total) {
        _status = 'Partial';
      } else {
        _status = 'Unpaid';
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null && widget.payment == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentData = {
        'patient_id': _selectedPatient?.id ?? widget.payment!.patientId,
        'total_amount': double.parse(_totalAmountController.text),
        'amount_paid': double.parse(_amountPaidController.text),
        'payment_method': _paymentMethod,
        'status': _status,
      };

      if (widget.payment == null) {
        await paymentsRepository.createPayment(paymentData);
      } else {
        await paymentsRepository.updatePayment(widget.payment!.id, paymentData);
      }

      ref.invalidate(paymentsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.payment == null ? 'Payment added successfully' : 'Payment updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.payment == null ? 'Record Payment' : 'Edit Payment', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {
                  final patientsAsync = ref.watch(patientsProvider);
                  return patientsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text("Error loading patients"),
                    data: (patients) {
                      if (widget.payment != null && _selectedPatient == null) {
                        try {
                          _selectedPatient = patients.firstWhere((p) => p.id == widget.payment!.patientId);
                        } catch (_) {}
                      }

                      return DropdownButtonFormField<Patient>(
                        decoration: const InputDecoration(labelText: "Patient"),
                        value: _selectedPatient,
                        items: patients.map((patient) {
                          return DropdownMenuItem(
                            value: patient,
                            child: Text(patient.fullName),
                          );
                        }).toList(),
                        onChanged: widget.payment != null ? null : (patient) {
                          setState(() {
                            _selectedPatient = patient;
                          });
                        },
                        validator: (value) => value == null ? "Required" : null,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalAmountController,
                      decoration: const InputDecoration(labelText: 'Total Bill (\$)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onChanged: (_) => _calculateStatus(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountPaidController,
                      decoration: const InputDecoration(labelText: 'Amount Paid (\$)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onChanged: (_) => _calculateStatus(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Payment Method'),
                value: _paymentMethod,
                items: ['Cash', 'Mobile Money']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),

              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Calculated Status: $_status', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _status == 'Paid' ? Colors.green : _status == 'Partial' ? Colors.orange : Colors.red,
                  )
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Payment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
