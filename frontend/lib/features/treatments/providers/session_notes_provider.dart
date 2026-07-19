import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/session_note_model.dart';
import '../data/treatments_repository.dart';

final sessionNotesProvider = FutureProvider.family<List<SessionNote>, int>((ref, planId) async {
  final data = await treatmentsRepository.getSessionNotes(planId);
  return data.map((json) => SessionNote.fromJson(json)).toList();
});
