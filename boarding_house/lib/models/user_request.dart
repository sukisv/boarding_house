class UserRequest {
  final String email;
  final String password;

  UserRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
