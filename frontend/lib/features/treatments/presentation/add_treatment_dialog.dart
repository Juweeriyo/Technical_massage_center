import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/treatment_model.dart';
import '../data/treatments_repository.dart';
import '../providers/treatments_provider.dart';
import '../../patients/providers/patients_provider.dart';
import '../../patients/data/patient_model.dart';
import '../../auth/providers/doctors_provider.dart';
import '../../auth/data/user_model.dart';

class AddTreatmentDialog extends ConsumerStatefulWidget {
  final TreatmentPlan? treatment;

  const AddTreatmentDialog({super.key, this.treatment});

  @override
  ConsumerState<AddTreatmentDialog> createState() => _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends ConsumerState<AddTreatmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _treatmentNameController = TextEditingController();
  final _sessionsController = TextEditingController();
  final _startDateController = TextEditingController();
  int _mode = 1;
  String _status = 'Active';
  Patient? _selectedPatient;
  User? _selectedDoctor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.treatment != null) {
      _treatmentNameController.text = widget.treatment!.treatmentName;
      _sessionsController.text = widget.treatment!.numberOfSessions.toString();
      _startDateController.text = widget.treatment!.startDate;
      _mode = widget.treatment!.mode;
      _status = widget.treatment!.status;
    }
  }

  @override
  void dispose() {
    _treatmentNameController.dispose();
    _sessionsController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null && widget.treatment == null) return;
    if (_selectedDoctor == null && widget.treatment == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final treatmentData = {
        'patient_id': _selectedPatient?.id ?? widget.treatment!.patientId,
        'doctor_id': _selectedDoctor?.id ?? widget.treatment!.doctorId,
        'treatment_name': _treatmentNameController.text,
        'mode': _mode,
        'number_of_sessions': int.parse(_sessionsController.text),
        'start_date': _startDateController.text,
        'status': _status,
      };

      if (widget.treatment == null) {
        await treatmentsRepository.createTreatment(treatmentData);
      } else {
        await treatmentsRepository.updateTreatment(widget.treatment!.id, treatmentData);
      }

      ref.invalidate(treatmentsProvider);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.treatment == null ? 'Treatment created successfully' : 'Treatment updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving treatment: $e')),
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
              Text(widget.treatment == null ? 'Create Treatment Plan' : 'Edit Treatment Plan', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {
                  final patientsAsync = ref.watch(patientsProvider);
                  return patientsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text("Error loading patients"),
                    data: (patients) {
                      if (widget.treatment != null && _selectedPatient == null) {
                        try {
                          _selectedPatient = patients.firstWhere((p) => p.id == widget.treatment!.patientId);
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
                        onChanged: (patient) {
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
              
              Consumer(
                builder: (context, ref, child) {
                  final doctorsAsync = ref.watch(doctorsProvider);
                  return doctorsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text("Error loading doctors"),
                    data: (doctors) {
                      if (widget.treatment != null && _selectedDoctor == null) {
                        try {
                          _selectedDoctor = doctors.firstWhere((d) => d.id == widget.treatment!.doctorId);
                        } catch (_) {}
                      }

                      return DropdownButtonFormField<User>(
                        decoration: const InputDecoration(labelText: "Doctor"),
                        value: _selectedDoctor,
                        items: doctors.map((doctor) {
                          return DropdownMenuItem(
                            value: doctor,
                            child: Text(doctor.username),
                          );
                        }).toList(),
                        onChanged: (doctor) {
                          setState(() {
                            _selectedDoctor = doctor;
                          });
                        },
                        validator: (value) => value == null ? "Required" : null,
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
                value: _mode,
                decoration: const InputDecoration(labelText: 'Massage Mode'),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sessionsController,
                      decoration: const InputDecoration(labelText: 'Sessions'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              
              if (widget.treatment != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: _status,
                    items: ['Active', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _status = val!;
                      });
                    },
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
                        : Text(widget.treatment == null ? 'Create Plan' : 'Save'),
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
