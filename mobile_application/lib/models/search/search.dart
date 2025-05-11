class Search {
  final String id;
  final String query;

  Search({required this.id, required this.query});

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(id: json['id'], query: json['query']);
  }
}
