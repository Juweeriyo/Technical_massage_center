import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceragem_somalia/core/network/api_client.dart';

class AuthService {


  Future<bool> login(String username, String password) async {
  try {
    final response = await apiClient.postForm('/auth/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', token);

      // Get logged-in user details
      final userResponse = await apiClient.get('/auth/me');

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);

        await prefs.setString('role', userData['role']);
        await prefs.setString('username', userData['username']);
      }

      return true;
    }

    return false;
  } catch (e) {
    print(e);
    return false;
  }
}




  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('role');
    await prefs.remove('username');
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  Future<String?> getRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

}
