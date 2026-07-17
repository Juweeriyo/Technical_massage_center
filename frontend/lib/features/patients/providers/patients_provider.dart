import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/patient_model.dart';
import '../data/patients_repository.dart';

final patientsProvider = FutureProvider<List<Patient>>((ref) async {
  return await patientsRepository.getPatients();
});

final searchPatientsProvider = FutureProvider.family<List<Patient>, String>((ref, query) async {
  if (query.isEmpty) {
    return await patientsRepository.getPatients();
  }
  return await patientsRepository.searchPatients(query);
});
