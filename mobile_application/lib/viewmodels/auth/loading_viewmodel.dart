import 'package:flutter/material.dart';
import 'package:mobile_application/services/api_service.dart';

class LoadingViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<bool> checkLoginStatus() async {
    try {
      final response = await _apiService.get('/users/me');
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
