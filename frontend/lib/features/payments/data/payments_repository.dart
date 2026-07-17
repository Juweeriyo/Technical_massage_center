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
}

final paymentsRepository = PaymentsRepository();
