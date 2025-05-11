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
    );
  }

  String getGenderLabel() {
    const genderMapping = {
      'male': 'Putra',
      'female': 'Putri',
      'mixed': 'Campur',
    };
    return genderMapping[genderAllowed] ?? 'Tidak Diketahui';
  }
}
