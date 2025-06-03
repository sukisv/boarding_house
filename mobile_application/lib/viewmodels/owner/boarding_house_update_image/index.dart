import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/services/api_service.dart';

class BoardingHouseUpdateImageViewModel extends ChangeNotifier {
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

  Future<void> uploadImages(String boardingHouseId, List<File> files) async {
    try {
      final imagePaths = files.map((file) => file.path).toList();
      await _apiService.uploadBoardingHouseImages(
        '/api/boarding-house-images',
        boardingHouseId,
        imagePaths,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading images: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteImage(String boardingHouseId, String imageId) async {
    try {
      await _apiService.delete('/api/boarding-house-images/$imageId');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      rethrow;
    }
  }

  String getFullImageUrl(String imageUrl) {
    try {
      final cleaned = imageUrl.replaceAll('\\', '/');
      if (cleaned.startsWith('/')) {
        return _apiService.baseUrl + cleaned;
      } else {
        return '${_apiService.baseUrl}/$cleaned';
      }
    } catch (e) {
      return '';
    }
  }
}
