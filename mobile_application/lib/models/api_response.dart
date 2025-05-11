abstract class ApiResponse<T> {
  final T data;
  final String message;

  ApiResponse({required this.data, required this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseImpl(
      data: fromJsonT(json['data']),
      message: json['message'],
    );
  }
}

class ApiResponseImpl<T> extends ApiResponse<T> {
  ApiResponseImpl({required T data, required String message})
    : super(data: data, message: message);
}
