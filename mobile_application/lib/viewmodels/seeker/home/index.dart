import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 10;
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
      isLoading = false;
      notifyListeners();
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

  // Method to handle search data
  void handleSearchData(String search, String column) {
    print('Search: $search, Column: $column');
    notifyListeners();
  }

  // Method to handle search data and fetch filtered results
  Future<void> applySearch(String search, String column, String value) async {
    isLoading = true;
    notifyListeners();

    try {
      // Build the URL with query parameters
      final url =
          '/api/boarding-houses?page=$currentPage&limit=$limit&search=$search&$column=$value';

      // Make API request
      final response = await _apiService.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final houses = data['data'] as List;

        // Map API response to BoardingHouse model
        boardingHouses = houses.map((e) => BoardingHouse.fromJson(e)).toList();
      } else {
        print('Failed to fetch data: ${response.body}');
      }
    } catch (e) {
      print('Error applying search: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
