import 'package:mobile_application/models/user.dart';

class BoardingHouse {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String city;
  final int pricePerMonth;
  final int roomAvailable;
  final String genderAllowed;
  final List<Facility> facilities;
  final List<BoardingHouseImage> images;
  final User owner;
  final int bookedCount;
  final int availableCount;

  BoardingHouse({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.pricePerMonth,
    required this.roomAvailable,
    required this.genderAllowed,
    required this.facilities,
    required this.images,
    required this.bookedCount,
    required this.availableCount,
    required this.owner,
  });

  factory BoardingHouse.fromJson(Map<String, dynamic> json) {
    return BoardingHouse(
      id: json['id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pricePerMonth: json['price_per_month'] ?? 0,
      roomAvailable: json['room_available'] ?? 0,
      genderAllowed: json['gender_allowed'] ?? '',
      facilities:
          (json['facilities'] as List<dynamic>?)
              ?.map((facilityJson) => Facility.fromJson(facilityJson))
              .toList() ??
          [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((imgJson) => BoardingHouseImage.fromJson(imgJson))
              .toList() ??
          [],
      bookedCount: json['booked_count'] ?? 0,
      availableCount: json['available_count'] ?? 0,
      owner: User.fromJson(json['owner'] ?? {}),
    );
  }

  static String getGenderLabelStatic(String gender) {
    const genderMapping = {
      'male': 'Putra',
      'female': 'Putri',
      'mixed': 'Campur',
    };
    return genderMapping[gender] ?? 'Tidak Diketahui';
  }
}

class Facility {
  final String id;
  final String name;

  Facility({required this.id, required this.name});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(id: json['id'], name: json['name']);
  }
}

class BoardingHouseImage {
  final String id;
  final String boardingHouseId;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;

  BoardingHouseImage({
    required this.id,
    required this.boardingHouseId,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardingHouseImage.fromJson(Map<String, dynamic> json) {
    return BoardingHouseImage(
      id: json['id'],
      boardingHouseId: json['boarding_house_id'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
