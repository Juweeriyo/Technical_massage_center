import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/patient_model.dart';

class PatientProfileDialog extends StatelessWidget {
  final Patient patient;

  const PatientProfileDialog({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Patient Profile', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Patient ID', patient.patientNumber),
            const Divider(),
            _buildInfoRow('Full Name', patient.fullName),
            const Divider(),
            _buildInfoRow('Phone Number', patient.phoneNumber),
            const Divider(),
            _buildInfoRow('Age & Gender', '${patient.age} / ${patient.gender}'),
            const Divider(),
            _buildInfoRow('Address', patient.address),
            const Divider(),
            _buildInfoRow('Registration Date', _formatDate(patient.registrationDate)),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Medical Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                patient.medicalNotes?.isNotEmpty == true
                    ? patient.medicalNotes!
                    : 'No medical notes provided.',
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
