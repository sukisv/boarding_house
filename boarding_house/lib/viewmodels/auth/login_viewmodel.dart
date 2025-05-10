import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user_request.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService('http://localhost:8080');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login() async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      final userRequest = UserRequest(
        email: emailController.text,
        password: passwordController.text,
      );

      final response = await _apiService.post(
        '/auth/login',
        userRequest.toJson(),
      );

      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('An error occurred: $e');
      _setLoading(false);
      return false;
    }
  }
}
