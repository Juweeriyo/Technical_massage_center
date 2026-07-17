import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/diagnoses_repository.dart';
import '../providers/diagnoses_provider.dart';

class AddDiagnosisDialog extends ConsumerStatefulWidget {
  const AddDiagnosisDialog({super.key});

  @override
  ConsumerState<AddDiagnosisDialog> createState() => _AddDiagnosisDialogState();
}

class _AddDiagnosisDialogState extends ConsumerState<AddDiagnosisDialog> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _doctorIdController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _recommendationsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _patientIdController.dispose();
    _doctorIdController.dispose();
    _symptomsController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await diagnosesRepository.createDiagnosis({
        'patient_id': int.parse(_patientIdController.text),
        'doctor_id': int.parse(_doctorIdController.text),
        'symptoms': _symptomsController.text,
        'recommendations': _recommendationsController.text,
      });
      ref.invalidate(diagnosesProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnosis added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding diagnosis: $e')),
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
              Text('Add Diagnosis', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _patientIdController,
                decoration: const InputDecoration(labelText: 'Patient ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
                controller: _symptomsController,
                decoration: const InputDecoration(labelText: 'Symptoms'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recommendationsController,
                decoration: const InputDecoration(labelText: 'Recommendations'),
                maxLines: 3,
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
                        : const Text('Save'),
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
