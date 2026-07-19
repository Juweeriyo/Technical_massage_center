import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/treatment_model.dart';
import '../providers/session_notes_provider.dart';
import 'add_session_note_dialog.dart';
import '../../auth/providers/doctors_provider.dart';

class TreatmentHistoryDialog extends ConsumerWidget {
  final TreatmentPlan treatment;

  const TreatmentHistoryDialog({super.key, required this.treatment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(sessionNotesProvider(treatment.id));
    final doctorsAsync = ref.watch(doctorsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Treatment History: ${treatment.treatmentName}', 
                     style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status: ${treatment.status} | Sessions: ${treatment.numberOfSessions}', 
                 style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            
            Expanded(
              child: notesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (notes) {
                  if (notes.isEmpty) {
                    return const Center(child: Text("No session notes recorded yet."));
                  }
                  
                  return doctorsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error loading doctors: $err')),
                    data: (doctors) {
                      final doctorMap = {for (var d in doctors) d.id: d};

                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final doctorName = doctorMap[note.doctorId]?.username ?? 'Unknown Doctor';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(note.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('Pain Level: ${note.painLevel}/10', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('By: $doctorName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 12),
                                  
                                  const Text('Patient Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(note.patientResponse),
                                  const SizedBox(height: 8),
                                  
                                  const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(note.notes),
                                  
                                  if (note.nextRecommendation != null && note.nextRecommendation!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text('Recommendation:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(note.nextRecommendation!),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            if (treatment.status != 'Completed')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddSessionNoteDialog(treatmentPlanId: treatment.id),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Session Note'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
