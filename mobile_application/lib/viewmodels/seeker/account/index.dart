import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_application/models/booking.dart';
import 'package:mobile_application/services/api_service.dart';

class AccountViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  Future<List<Booking>> fetchBookings() async {
    try {
      final response = await _apiService.get('/api/bookings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        return data.map((e) => Booking.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching bookings: $e');
      }
      return [];
    }
  }

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
