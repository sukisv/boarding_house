import 'package:flutter/material.dart';
import 'package:mobile_application/services/api_service.dart';
import 'package:mobile_application/models/user.dart';
import 'user_provider.dart';
import 'dart:convert';

class LoadingViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<bool> checkLoginStatus(UserProvider userProvider) async {
    try {
      final response = await _apiService.get('/api/users/me');
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final user = User.fromJson(userData['data']);
        userProvider.setUser(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
