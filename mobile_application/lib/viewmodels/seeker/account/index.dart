import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      notifyListeners(); // Notify listeners if needed
    } catch (e) {
      print('Logout exception: $e');
    }
  }

  // Add properties and methods specific to Account page
}
