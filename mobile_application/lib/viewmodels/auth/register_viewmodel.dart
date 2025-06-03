import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone_number': phone,
        },
      );
      if (response.statusCode == 200) {
        // Handle successful registration
        return true;
      } else {
        // Handle registration error
        return false;
      }
    } catch (e) {
      // Handle exception
      return false;
    }
  }
}
