import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/appointment_model.dart';
import '../data/appointments_repository.dart';
import '../providers/appointments_provider.dart';
import '../../patients/providers/patients_provider.dart';
import '../../patients/data/patient_model.dart';
import '../../auth/providers/doctors_provider.dart';
import '../../auth/data/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class AddAppointmentDialog extends ConsumerStatefulWidget {
  final Appointment? appointment;

  const AddAppointmentDialog({super.key, this.appointment});

  @override
  ConsumerState<AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends ConsumerState<AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  Patient? _selectedPatient;
  User? _selectedDoctor;
  String _status = 'Scheduled';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _dateController.text = widget.appointment!.date;
      _timeController.text = widget.appointment!.time;
      _status = widget.appointment!.status;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null && widget.appointment == null) return;
    if (_selectedDoctor == null && widget.appointment == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentData = {
        'patient_id': _selectedPatient?.id ?? widget.appointment!.patientId,
        'doctor_id': _selectedDoctor?.id ?? widget.appointment!.doctorId,
        'date': _dateController.text,
        'time': _timeController.text,
        'status': _status,
      };

      if (widget.appointment == null) {
        await appointmentsRepository.createAppointment(appointmentData);
      } else {
        await appointmentsRepository.updateAppointment(widget.appointment!.id, appointmentData);
      }
      
      ref.invalidate(appointmentsProvider);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.appointment == null ? 'Appointment booked successfully' : 'Appointment updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving appointment: $e')),
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
    final roleAsync = ref.watch(userRoleProvider);
    final isDoctor = roleAsync.value == 'Doctor';

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
              Text(widget.appointment == null ? 'Book Appointment' : 'Edit Appointment', 
                   style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),
              
              // Patient Dropdown
              Consumer(
                builder: (context, ref, child) {
                  final patientsAsync = ref.watch(patientsProvider);
                  return patientsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text("Error loading patients"),
                    data: (patients) {
                      if (widget.appointment != null && _selectedPatient == null) {
                        try {
                          _selectedPatient = patients.firstWhere((p) => p.id == widget.appointment!.patientId);
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
                        onChanged: isDoctor ? null : (patient) {
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
              
              // Doctor Dropdown
              Consumer(
                builder: (context, ref, child) {
                  final doctorsAsync = ref.watch(doctorsProvider);
                  return doctorsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text("Error loading doctors"),
                    data: (doctors) {
                      if (widget.appointment != null && _selectedDoctor == null) {
                        try {
                          _selectedDoctor = doctors.firstWhere((d) => d.id == widget.appointment!.doctorId);
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
                        onChanged: isDoctor ? null : (doctor) {
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
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: isDoctor ? null : () => _selectDate(context),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: isDoctor ? null : () => _selectTime(context),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.appointment != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: _status,
                  items: ['Scheduled', 'Completed', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _status = val!;
                    });
                  },
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
                        : Text(widget.appointment == null ? 'Book' : 'Save'),
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
