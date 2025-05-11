class Account {
  final String id;
  final String name;
  final String email;

  Account({required this.id, required this.name, required this.email});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(id: json['id'], name: json['name'], email: json['email']);
  }
}
