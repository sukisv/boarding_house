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
  });

  factory BoardingHouse.fromJson(Map<String, dynamic> json) {
    return BoardingHouse(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      pricePerMonth: json['price_per_month'],
      roomAvailable: json['room_available'],
      genderAllowed: json['gender_allowed'],
      facilities:
          (json['facilities'] as List<dynamic>?)
              ?.map((facilityJson) => Facility.fromJson(facilityJson))
              .toList() ??
          [],
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
