import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diagnoses_provider.dart';
import 'add_diagnosis_dialog.dart';

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnoses & Session Notes'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Container(
        color: AppColors.lightGray,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Diagnoses', style: Theme.of(context).textTheme.displayLarge),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddDiagnosisDialog(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Diagnosis'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // State for Diagnoses
            Expanded(
              child: ref.watch(diagnosesProvider).when(
                data: (diagnoses) {
                  if (diagnoses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.medical_services_outlined, size: 48, color: AppColors.border),
                          const SizedBox(height: 12),
                          Text(
                            'No diagnoses found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.darkGray),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: diagnoses.length,
                    itemBuilder: (context, index) {
                      final d = diagnoses[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.medical_services_outlined),
                          title: Text('Patient ID: ${d.patientId} • Doctor ID: ${d.doctorId}'),
                          subtitle: Text('Symptoms: ${d.symptoms}\nRecommendations: ${d.recommendations}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
