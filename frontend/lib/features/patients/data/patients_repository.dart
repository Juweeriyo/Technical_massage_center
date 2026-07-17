import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'patient_model.dart';

class PatientsRepository {
  Future<List<Patient>> getPatients() async {
    final response = await apiClient.get('/patients/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    }
    throw Exception('Failed to load patients');
  }

  Future<List<Patient>> searchPatients(String query) async {
    final response = await apiClient.get('/patients/search?query=$query');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    }
    throw Exception('Failed to search patients');
  }

  Future<Patient> createPatient(Map<String, dynamic> patientData) async {
    final response = await apiClient.post('/patients/', patientData);
    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create patient');
  }
}

Future<Patient> updatePatient(
  int id,
  Map<String, dynamic> patientData,
) async {

  final response = await apiClient.put(
    '/patients/$id',
    patientData,
  );

  if (response.statusCode == 200) {
    return Patient.fromJson(jsonDecode(response.body));
  }

  throw Exception('Failed to update patient');
}

Future<void> deletePatient(int id) async {

  final response = await apiClient.delete(
    '/patients/$id',
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete patient');
  }
}

final patientsRepository = PatientsRepository();
