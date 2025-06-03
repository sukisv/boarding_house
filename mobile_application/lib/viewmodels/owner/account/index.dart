import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_application/services/api_service.dart';
import 'package:mobile_application/viewmodels/auth/user_provider.dart';
import 'dart:convert';
import 'package:mobile_application/models/user.dart';

class AccountViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  Future<void> logout(UserProvider userProvider) async {
    try {
      await _storage.delete(key: 'auth_token');
      userProvider.clearUser();
      notifyListeners();
    } catch (e) {
      if (e.toString().contains(
        'OS Error: The process cannot access the file',
      )) {
        if (kDebugMode) {
          print('Logout failed: Storage is being used by another process.');
        }
      } else {
        if (kDebugMode) {
          print('Logout exception: $e');
        }
      }
    }
  }

  Future<User?> updateUser(
    String userId,
    String name,
    String email,
    String phone,
  ) async {
    try {
      final response = await _apiService.put(
        '/api/users/$userId',
        body: {'name': name, 'email': email, 'phone_number': phone},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> res = json.decode(response.body);
        var user = User.fromJson(res['data']);

        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
