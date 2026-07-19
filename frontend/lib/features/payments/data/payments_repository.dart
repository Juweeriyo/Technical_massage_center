import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'payment_model.dart';

class PaymentsRepository {
  Future<List<Payment>> getPayments() async {
    final response = await apiClient.get('/payments/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    }
    throw Exception('Failed to load payments');
  }

  Future<Payment> createPayment(Map<String, dynamic> paymentData) async {
    final response = await apiClient.post('/payments/', paymentData);
    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create payment');
  }

  Future<Payment> updatePayment(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/payments/$id', data);
    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update payment');
  }

  Future<void> deletePayment(int id) async {
    final response = await apiClient.delete('/payments/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete payment');
    }
  }

  Future<String> getPatientPaymentStatus(int patientId) async {
    final response = await apiClient.get('/payments/patient/$patientId/status');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    }
    return "Unknown";
  }
}

final paymentsRepository = PaymentsRepository();
