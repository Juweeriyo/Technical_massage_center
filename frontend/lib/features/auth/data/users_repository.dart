import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'user_model.dart';

class UsersRepository {
  Future<List<User>> getDoctors() async {
    final response = await apiClient.get('/users/doctors');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load doctors');
  }
}

final usersRepository = UsersRepository();
