class Home {
  final String id;
  final String title;
  final String description;

  Home({required this.id, required this.title, required this.description});

  factory Home.fromJson(Map<String, dynamic> json) {
    return Home(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
