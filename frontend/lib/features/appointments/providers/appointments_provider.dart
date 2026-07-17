import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appointment_model.dart';
import '../data/appointments_repository.dart';

final appointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  return await appointmentsRepository.getAppointments();
});
