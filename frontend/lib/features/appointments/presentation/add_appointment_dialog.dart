import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/appointments_repository.dart';
import '../providers/appointments_provider.dart';
import '../../patients/providers/patients_provider.dart';
import '../../patients/data/patient_model.dart';

class AddAppointmentDialog extends ConsumerStatefulWidget {
  const AddAppointmentDialog({super.key});

  @override
  ConsumerState<AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends ConsumerState<AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  // final _patientIdController = TextEditingController();
  final _doctorIdController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  Patient? _selectedPatient;
  bool _isLoading = false;

  @override
  void dispose() {
    _doctorIdController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await appointmentsRepository.createAppointment({
        'patient_id': _selectedPatient!.id,
        'doctor_id': int.parse(_doctorIdController.text),
        'date': _dateController.text,
        'time': _timeController.text,
        'status': 'Scheduled',
      });
      ref.invalidate(appointmentsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking appointment: $e')),
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
              Text('Book Appointment', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {

                  final patientsAsync = ref.watch(patientsProvider);

                  return patientsAsync.when(

                    loading: () => const CircularProgressIndicator(),

                    error: (error, stack) =>
                        const Text("Error loading patients"),

                    data: (patients) {

                      return DropdownButtonFormField<Patient>(

                        decoration: const InputDecoration(
                          labelText: "Patient",
                        ),

                        value: _selectedPatient,

                        items: patients.map((patient) {

                          return DropdownMenuItem(
                            value: patient,
                            child: Text(patient.fullName),
                          );

                        }).toList(),

                        onChanged: (patient) {

                          setState(() {
                            _selectedPatient = patient;
                          });

                        },

                        validator: (value) =>
                            value == null ? "Required" : null,

                      );

                    },

                  );

                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorIdController,
                decoration: const InputDecoration(labelText: 'Doctor ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
                        : const Text('Book'),
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
