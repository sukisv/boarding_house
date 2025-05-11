import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 15;
  List<BoardingHouse> boardingHouses = [];

  HomeViewModel() {
    fetchBoardingHouses();
  }

  Future<void> fetchBoardingHouses() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/api/boarding-houses?page=$currentPage&limit=$limit',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        boardingHouses.addAll(
          data.map((e) => BoardingHouse.fromJson(e)).toList(),
        );
        currentPage++;
      }
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void fetchNextPage() {
    if (!isLoading) {
      fetchBoardingHouses();
    }
  }
}
