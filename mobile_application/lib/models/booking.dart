import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/models/user.dart';

class Booking {
  final String id;
  final String userId;
  final String boardingHouseId;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;
  final String updatedAt;
  final User user;
  final BoardingHouse boardingHouse;

  Booking({
    required this.id,
    required this.userId,
    required this.boardingHouseId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.boardingHouse,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      boardingHouseId: json['boarding_house_id'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      boardingHouse: BoardingHouse.fromJson(json['boarding_house'] ?? {}),
    );
  }
}

enum BookingStatus { pending, confirmed, cancelled }

BookingStatus bookingStatusFromString(String status) {
  switch (status) {
    case 'pending':
      return BookingStatus.pending;
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'cancelled':
      return BookingStatus.cancelled;
    default:
      return BookingStatus.pending;
  }
}

String bookingStatusToString(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return 'pending';
    case BookingStatus.confirmed:
      return 'confirmed';
    case BookingStatus.cancelled:
      return 'cancelled';
  }
}
