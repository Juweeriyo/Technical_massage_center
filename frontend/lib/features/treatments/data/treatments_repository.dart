import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'treatment_model.dart';

class TreatmentsRepository {
  Future<List<TreatmentPlan>> getTreatments() async {
    final response = await apiClient.get('/treatments/plans');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TreatmentPlan.fromJson(json)).toList();
    }
    throw Exception('Failed to load treatments');
  }

  Future<TreatmentPlan> createTreatment(
      Map<String, dynamic> treatmentData) async {
    final response = await apiClient.post('/treatments/plans', treatmentData);
    if (response.statusCode == 200) {
      return TreatmentPlan.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create treatment');
  }

  Future<TreatmentPlan> updateTreatment(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/treatments/plans/$id', data);
    if (response.statusCode == 200) {
      return TreatmentPlan.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update treatment');
  }

  Future<List<dynamic>> getSessionNotes(int planId) async {
    final response = await apiClient.get('/treatments/sessions/$planId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load session notes');
  }

  Future<dynamic> createSessionNote(Map<String, dynamic> data) async {
    final response = await apiClient.post('/treatments/sessions', data);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create session note');
  }
}

final treatmentsRepository = TreatmentsRepository();
