import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'appointment_model.dart';

class AppointmentsRepository {
  Future<List<Appointment>> getAppointments() async {
    final response = await apiClient.get('/appointments/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    }
    throw Exception('Failed to load appointments');
  }

  Future<Appointment> createAppointment(Map<String, dynamic> appointmentData) async {
    final response = await apiClient.post('/appointments/', appointmentData);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create appointment');
  }

  Future<Appointment> updateAppointment(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/appointments/$id', data);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update appointment');
  }

  Future<void> cancelAppointment(int id) async {
    final response = await apiClient.put('/appointments/$id/cancel', {});
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel appointment');
    }
  }

  Future<void> deleteAppointment(int id) async {
    final response = await apiClient.delete('/appointments/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete appointment');
    }
  }
}

final appointmentsRepository = AppointmentsRepository();
