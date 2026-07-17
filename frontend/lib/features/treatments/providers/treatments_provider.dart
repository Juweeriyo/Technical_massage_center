import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/treatment_model.dart';
import '../data/treatments_repository.dart';

final treatmentsProvider = FutureProvider<List<TreatmentPlan>>((ref) async {
  return await treatmentsRepository.getTreatments();
});
