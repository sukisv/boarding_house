class ResponseModel {
  final bool success;
  final String message;
  final String status; // Tambahkan properti status
  final dynamic? data; // Tetap nullable untuk menampung err.Error()

  ResponseModel({
    required this.success,
    required this.message,
    required this.status, // Tambahkan ke konstruktor
    this.data,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      success: json['success'],
      message: json['message'],
      status: json['status'], // Parsing status dari JSON
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status, // Tambahkan ke JSON
      'data': data,
    };
  }
}
