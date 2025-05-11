import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String emailOrPhone, String password) async {
    try {
      final isEmail = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(emailOrPhone);
      final isPhone = RegExp(r'^(08|6)').hasMatch(emailOrPhone);

      final body = {
        if (isEmail) 'email': emailOrPhone,
        if (isPhone) 'phone': emailOrPhone,
        'password': password,
      };

      final response = await _apiService.post('/auth/login', body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['data']['token'];

        await _storage.write(key: 'auth_token', value: token);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login exception: $e');
      return false;
    }
  }
}
