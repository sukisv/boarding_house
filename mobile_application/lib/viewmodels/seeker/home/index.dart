import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/booking.dart';
import 'package:mobile_application/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
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
}
