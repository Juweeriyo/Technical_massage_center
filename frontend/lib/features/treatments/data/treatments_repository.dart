import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'treatment_model.dart';

class TreatmentsRepository {
  Future<List<TreatmentPlan>> getTreatments() async {
    final response = await apiClient.get('/treatments/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TreatmentPlan.fromJson(json)).toList();
    }
    throw Exception('Failed to load treatments');
  }

  Future<TreatmentPlan> createTreatment(Map<String, dynamic> treatmentData) async {
    final response = await apiClient.post('/treatments/plans', treatmentData);
    if (response.statusCode == 200) {
      return TreatmentPlan.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create treatment');
  }
}

final treatmentsRepository = TreatmentsRepository();
