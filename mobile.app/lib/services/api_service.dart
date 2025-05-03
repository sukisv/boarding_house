import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/response_model.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // GET Request
  Future<ResponseModel> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        return ResponseModel.fromJson(json.decode(response.body));
      } else {
        return ResponseModel(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseModel(success: false, message: 'Exception: $e');
    }
  }

  // POST Request
  Future<ResponseModel> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResponseModel.fromJson(json.decode(response.body));
      } else {
        return ResponseModel(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseModel(success: false, message: 'Exception: $e');
    }
  }

  // PUT Request
  Future<ResponseModel> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return ResponseModel.fromJson(json.decode(response.body));
      } else {
        return ResponseModel(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseModel(success: false, message: 'Exception: $e');
    }
  }

  // DELETE Request
  Future<ResponseModel> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        return ResponseModel.fromJson(json.decode(response.body));
      } else {
        return ResponseModel(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseModel(success: false, message: 'Exception: $e');
    }
  }
}
