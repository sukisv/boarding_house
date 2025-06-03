import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/services/api_service.dart';

class SearchViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 10;
  List<BoardingHouse> boardingHouses = [];
  String lastKeyword = '';
  String lastGender = 'all';

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

  Future<void> applySearch(String search, String gender, [String? city]) async {
    isLoading = true;
    notifyListeners();
    currentPage = 1;
    lastKeyword = search;
    lastGender = gender;
    try {
      String url;
      if (city != null && city.isNotEmpty) {
        url =
            '/api/boarding-houses?page=$currentPage&limit=$limit&city=$city&gender_allowed=$gender';
      } else {
        url =
            '/api/boarding-houses?page=$currentPage&limit=$limit&search=$search&gender_allowed=$gender';
      }
      final response = await _apiService.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final houses = data['data'] as List;
        boardingHouses = houses.map((e) => BoardingHouse.fromJson(e)).toList();
        currentPage++;
      } else {
        boardingHouses = [];
      }
    } catch (e) {
      boardingHouses = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
