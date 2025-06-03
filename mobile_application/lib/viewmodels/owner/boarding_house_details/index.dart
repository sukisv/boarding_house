import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:mobile_application/services/api_service.dart';

class BoardingHouseDetailsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<BoardingHouse> fetchBoardingHouseDetails(String id) async {
    try {
      final response = await _apiService.get('/api/boarding-houses/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return BoardingHouse.fromJson(data);
      } else {
        throw Exception('Failed to load boarding house details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBoardingHouse(String id) async {
    try {
      final response = await _apiService.delete('/api/boarding-houses/$id');
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Boarding house deleted successfully.');
        }
      } else {
        throw Exception('Failed to delete boarding house.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting boarding house: $e');
      }
      rethrow;
    }
  }

  Future<String> fetchBoardingHouseImage(String imageUrl) async {
    try {
      return await _apiService.showImage(imageUrl);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching boarding house image: $e');
      }
      rethrow;
    }
  }

  String getFullImageUrl(String imageUrl) {
    final cleaned = imageUrl.replaceAll('\\', '/');
    if (cleaned.startsWith('/')) {
      return _apiService.baseUrl + cleaned;
    } else {
      return '${_apiService.baseUrl}/$cleaned';
    }
  }

  Future<bool> bookingBoardingHouse({
    required String boardingHouseId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'boarding_house_id': boardingHouseId,
      'start_date': dateFormat.format(startDate),
      'end_date': dateFormat.format(endDate),
    };
    final response = await _apiService.post('/api/bookings', body: body);
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
