import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_application/services/api_service.dart';

class HomeViewmodel {
  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final response = await ApiService().get('/api/dashboard');
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'confirmed': decodedResponse['data']['confirmed'] ?? 0,
          'pending': decodedResponse['data']['pending'] ?? 0,
          'cancelled': decodedResponse['data']['cancelled'] ?? 0,
          'error': null,
        };
      } else {
        return {
          'confirmed': 0,
          'pending': 0,
          'cancelled': 0,
          'error': decodedResponse['message'] ?? 'Failed to load data',
        };
      }
    } catch (e) {
      return {
        'confirmed': 0,
        'pending': 0,
        'cancelled': 0,
        'error': e.toString(),
      };
    }
  }
}
