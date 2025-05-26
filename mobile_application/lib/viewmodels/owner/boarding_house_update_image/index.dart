import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:http/http.dart' as http;
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
      var uri = Uri.parse('${_apiService.baseUrl}/api/boarding-house-images');
      var request = http.MultipartRequest('POST', uri);
      request.fields['boarding_house_id'] = boardingHouseId;
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }
      await request.send();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImage(String boardingHouseId, String imageId) async {
    try {
      await _apiService.delete('/api/boarding-house-images/$imageId');
    } catch (e) {
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
