import 'dart:convert';
import 'package:mobile_application/models/booking.dart';
import 'package:mobile_application/services/api_service.dart';

class OwnerNotificationViewModel {
  Future<Map<String, dynamic>> fetchBookingsPaged(
    String status,
    int page,
  ) async {
    try {
      final response = await ApiService().get(
        '/api/bookings?page=$page&status=$status',
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['data'] != null) {
        return {
          'bookings': List<Booking>.from(
            (decoded['data'] as List).map((e) => Booking.fromJson(e)),
          ),
          'meta': decoded['meta'] ?? {},
        };
      } else {
        return {'bookings': [], 'meta': {}};
      }
    } catch (e) {
      return {'bookings': [], 'meta': {}};
    }
  }
}
