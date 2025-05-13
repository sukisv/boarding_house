import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_application/viewmodels/auth/user_provider.dart';

class AccountViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> logout(UserProvider userProvider) async {
    try {
      await _storage.delete(key: 'auth_token');
      userProvider.clearUser(); // Clear user data from the provider
      notifyListeners();
    } catch (e) {
      if (e.toString().contains(
        'OS Error: The process cannot access the file',
      )) {
        print('Logout failed: Storage is being used by another process.');
      } else {
        print('Logout exception: $e');
      }
    }
  }

  // Add properties and methods specific to Account page
}
