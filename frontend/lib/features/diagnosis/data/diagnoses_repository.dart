import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'diagnosis_model.dart';
import 'session_note_model.dart';

class DiagnosesRepository {
  Future<List<Diagnosis>> getDiagnoses() async {
    final response = await apiClient.get('/diagnoses/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Diagnosis.fromJson(json)).toList();
    }
    throw Exception('Failed to load diagnoses');
  }

  Future<Diagnosis> createDiagnosis(Map<String, dynamic> data) async {
    final response = await apiClient.post('/diagnoses/', data);
    if (response.statusCode == 200) {
      return Diagnosis.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create diagnosis');
  }

  Future<List<SessionNote>> getSessionNotes(int treatmentPlanId) async {
    final response = await apiClient.get('/diagnoses/session-notes/treatment/$treatmentPlanId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SessionNote.fromJson(json)).toList();
    }
    throw Exception('Failed to load session notes');
  }

  Future<SessionNote> createSessionNote(Map<String, dynamic> data) async {
    final response = await apiClient.post('/diagnoses/session-notes/', data);
    if (response.statusCode == 200) {
      return SessionNote.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create session note');
  }
}

final diagnosesRepository = DiagnosesRepository();
