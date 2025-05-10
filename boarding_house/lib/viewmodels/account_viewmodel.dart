import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AccountViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService('http://localhost:8080');

  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setUserData(Map<String, dynamic>? data) {
    _userData = data;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      final response = await _apiService.get('/api/users/me');

      if (response.success) {
        _setUserData(response.data);
      } else {
        _setErrorMessage(response.message);
      }
    } catch (e) {
      _setErrorMessage('An error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }
}
