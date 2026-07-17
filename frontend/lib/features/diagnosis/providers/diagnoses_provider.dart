import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/diagnosis_model.dart';
import '../data/session_note_model.dart';
import '../data/diagnoses_repository.dart';

final diagnosesProvider = FutureProvider<List<Diagnosis>>((ref) async {
  return await diagnosesRepository.getDiagnoses();
});

final sessionNotesProvider = FutureProvider.family<List<SessionNote>, int>((ref, treatmentPlanId) async {
  return await diagnosesRepository.getSessionNotes(treatmentPlanId);
});
