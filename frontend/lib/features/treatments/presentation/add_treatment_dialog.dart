import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/treatments_repository.dart';
import '../providers/treatments_provider.dart';
import '../../patients/providers/patients_provider.dart';
import '../../patients/data/patient_model.dart';

class AddTreatmentDialog extends ConsumerStatefulWidget {
  const AddTreatmentDialog({super.key});

  @override
  ConsumerState<AddTreatmentDialog> createState() => _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends ConsumerState<AddTreatmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _treatmentNameController = TextEditingController();
  final _sessionsController = TextEditingController();
  final _startDateController = TextEditingController();
  int _mode = 1;
  Patient? _selectedPatient;
  bool _isLoading = false;
  

  @override
  void dispose() {
    _treatmentNameController.dispose();
    _sessionsController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await treatmentsRepository.createTreatment({
        'patient_id': _selectedPatient!.id,        'treatment_name': _treatmentNameController.text,
        'mode': _mode,
        'number_of_sessions': int.parse(_sessionsController.text),
        'start_date': _startDateController.text,
        'status': 'Active',
      });
      ref.invalidate(treatmentsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating treatment: $e')),
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
              Text('Create Treatment Plan', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),


           Consumer(
              builder: (context, ref, child) {

                final patientsAsync = ref.watch(patientsProvider);

                return patientsAsync.when(

                  loading: () => const CircularProgressIndicator(),

                  error: (error, stack) => Text(
                    "Error loading patients",
                  ),

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
                controller: _treatmentNameController,
                decoration: const InputDecoration(labelText: 'Treatment Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

               const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _mode,
                  decoration: const InputDecoration(
                    labelText: 'Massage Mode',
                  ),

                  items: List.generate(
                    9,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Mode ${index + 1}'),
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      _mode = value!;
                    });
                  },
                ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _sessionsController,
                decoration: const InputDecoration(labelText: 'Number of Sessions'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
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
                        : const Text('Create Plan'),
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
