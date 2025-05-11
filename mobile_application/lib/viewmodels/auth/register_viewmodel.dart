import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  void register({
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        body: {'email': email, 'phone': phone, 'password': password},
      );
      if (response.statusCode == 200) {
        // Handle successful registration
      } else {
        // Handle registration error
      }
    } catch (e) {
      // Handle exception
    }
  }
}
