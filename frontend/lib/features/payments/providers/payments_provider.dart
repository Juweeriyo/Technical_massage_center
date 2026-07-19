import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/payment_model.dart';
import '../data/payments_repository.dart';

final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  return await paymentsRepository.getPayments();
});

final patientPaymentStatusProvider = FutureProvider.family<String, int>((ref, patientId) async {
  return await paymentsRepository.getPatientPaymentStatus(patientId);
});
