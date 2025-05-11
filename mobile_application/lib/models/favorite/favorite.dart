class Favorite {
  final String id;
  final String item;

  Favorite({required this.id, required this.item});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(id: json['id'], item: json['item']);
  }
}
