import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/services/api_service.dart';
import 'dart:convert';

class ManagePropertyViewModel extends ChangeNotifier {
  ManagePropertyViewModel();

  List<BoardingHouse> boardingHouses = [];
  List<Facility> facilities = [];
  bool isLoading = false;
  int currentPage = 0;
  int totalPages = 1;

  Future<void> fetchFacilities() async {
    if (facilities.isNotEmpty) return; // Avoid re-fetching if already loaded

    isLoading = true;
    try {
      final response = await ApiService().get('/api/facilities');
      final decodedResponse = jsonDecode(response.body);
      final data = decodedResponse['data'] as List<dynamic>;
      facilities =
          data.map((facilityJson) => Facility.fromJson(facilityJson)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching facilities: $e');
      }
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchBoardingHouses({int limit = 10}) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(
        '/api/boarding-houses?limit=$limit',
      );
      final decodedResponse = jsonDecode(response.body);
      final data = decodedResponse['data'] as List<dynamic>;
      boardingHouses =
          data.map((houseJson) => BoardingHouse.fromJson(houseJson)).toList();
      currentPage = decodedResponse['meta']['page'];
      totalPages = decodedResponse['meta']['total_pages'];
    } catch (e) {
      print('Error fetching boarding houses: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBoardingHouse(BoardingHouse boardingHouse) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = {
        'name': boardingHouse.name,
        'description': boardingHouse.description,
        'address': boardingHouse.address,
        'city': boardingHouse.city,
        'price_per_month': boardingHouse.pricePerMonth,
        'room_available': boardingHouse.roomAvailable,
        'gender_allowed': boardingHouse.genderAllowed,
        'facilities': boardingHouse.facilities.map((f) => f.id).toList(),
      };

      final response = await ApiService().post(
        '/api/boarding-houses',
        body: data,
      );
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Boarding house created successfully.');
        }
        await fetchBoardingHouses(); // Refresh the list
      } else {
        throw Exception('Failed to create boarding house.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating boarding house: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners(); // Notify only when loading state changes
    }
  }

  Future<void> updateBoardingHouse(
    String id,
    BoardingHouse boardingHouse,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = {
        'name': boardingHouse.name,
        'description': boardingHouse.description,
        'address': boardingHouse.address,
        'city': boardingHouse.city,
        'price_per_month': boardingHouse.pricePerMonth,
        'room_available': boardingHouse.roomAvailable,
        'gender_allowed': boardingHouse.genderAllowed,
        'facilities': boardingHouse.facilities.map((f) => f.id).toList(),
        // 'images': boardingHouse.images,
      };

      await ApiService().put('/api/boarding-houses/$id', body: data);
    } catch (e) {
      print('Error updating boarding house: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBoardingHouse(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      await ApiService().delete('/api/boarding-houses/$id');
    } catch (e) {
      print('Error deleting boarding house: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage({int limit = 10}) async {
    if (isLoading || currentPage >= totalPages) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(
        '/api/boarding-houses?page=${currentPage + 1}&limit=$limit',
      );
      final decodedResponse = jsonDecode(response.body);
      final data = decodedResponse['data'] as List<dynamic>;
      final newHouses =
          data.map((houseJson) => BoardingHouse.fromJson(houseJson)).toList();

      boardingHouses.addAll(newHouses);
      currentPage = decodedResponse['meta']['page'];
      totalPages = decodedResponse['meta']['total_pages'];
    } catch (e) {
      print('Error fetching next page: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
