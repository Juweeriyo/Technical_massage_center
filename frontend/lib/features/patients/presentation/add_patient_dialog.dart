import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/patients_repository.dart';
import '../providers/patients_provider.dart';
import '../data/patient_model.dart';

class AddPatientDialog extends ConsumerStatefulWidget {
  final Patient? patient;

  const AddPatientDialog({
    super.key,
    this.patient,
  });

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  String _gender = 'Male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.patient != null) {
      _fullNameController.text = widget.patient!.fullName;

      _phoneController.text = widget.patient!.phoneNumber;

      _ageController.text = widget.patient!.age.toString();

      _addressController.text = widget.patient!.address;

      _medicalNotesController.text = widget.patient!.medicalNotes ?? "";

      _gender = widget.patient!.gender;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final patientData = {
        'full_name': _fullNameController.text,
        'phone_number': _phoneController.text,
        'gender': _gender,
        'age': int.parse(_ageController.text),
        'address': _addressController.text,
        'medical_notes': _medicalNotesController.text.isNotEmpty
            ? _medicalNotesController.text
            : null,
      };

      if (widget.patient == null) {
        // Add new patient
        await patientsRepository.createPatient(patientData);
      } else {
        // Update existing patient
        await patientsRepository.updatePatient(
          widget.patient!.id,
          patientData,
        );
      }

      // Refresh patient list
      ref.invalidate(patientsProvider);
      ref.invalidate(searchPatientsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding patient: $e')),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.patient == null ? 'Add New Patient' : 'Edit Patient',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                    labelText: 'Medical Notes (Optional)'),
                maxLines: 3,
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.patient == null
                                ? 'Save Patient'
                                : 'Update Patient',
                          ),
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
