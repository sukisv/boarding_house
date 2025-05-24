import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'dart:convert';

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
}
