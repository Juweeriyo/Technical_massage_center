import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/treatments_repository.dart';
import '../providers/session_notes_provider.dart';
import '../../auth/providers/doctors_provider.dart';
import '../../auth/data/user_model.dart';

class AddSessionNoteDialog extends ConsumerStatefulWidget {
  final int treatmentPlanId;

  const AddSessionNoteDialog({super.key, required this.treatmentPlanId});

  @override
  ConsumerState<AddSessionNoteDialog> createState() => _AddSessionNoteDialogState();
}

class _AddSessionNoteDialogState extends ConsumerState<AddSessionNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _patientResponseController = TextEditingController();
  final _notesController = TextEditingController();
  final _recommendationController = TextEditingController();
  double _painLevel = 5;
  User? _selectedDoctor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _patientResponseController.dispose();
    _notesController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctor == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await treatmentsRepository.createSessionNote({
        'treatment_plan_id': widget.treatmentPlanId,
        'doctor_id': _selectedDoctor!.id,
        'date': _dateController.text,
        'patient_response': _patientResponseController.text,
        'pain_level': _painLevel.toInt(),
        'notes': _notesController.text,
        'next_recommendation': _recommendationController.text,
      });

      ref.invalidate(sessionNotesProvider(widget.treatmentPlanId));
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session note added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding note: $e')),
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
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Session Note', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 24),

                Consumer(
                  builder: (context, ref, child) {
                    final doctorsAsync = ref.watch(doctorsProvider);
                    return doctorsAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => const Text("Error loading doctors"),
                      data: (doctors) {
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
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                const Text('Pain Level (1-10)'),
                Row(
                  children: [
                    const Text('1'),
                    Expanded(
                      child: Slider(
                        value: _painLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _painLevel.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _painLevel = value;
                          });
                        },
                      ),
                    ),
                    const Text('10'),
                  ],
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _patientResponseController,
                  decoration: const InputDecoration(labelText: 'Patient Response'),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _recommendationController,
                  decoration: const InputDecoration(labelText: 'Next Recommendation (Optional)'),
                  maxLines: 2,
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
                          : const Text('Save Note'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
