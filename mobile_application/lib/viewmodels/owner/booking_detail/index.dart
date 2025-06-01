import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_application/models/booking.dart';
import 'package:mobile_application/services/api_service.dart';

class BookingDetailViewModel extends ChangeNotifier {
  Future<Booking?> fetchBookingDetail(String bookingId) async {
    try {
      final response = await ApiService().get('/api/bookings/$bookingId');
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['data'] != null) {
        return Booking.fromJson(decoded['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await ApiService().put(
        '/api/bookings/$bookingId/status',
        body: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
