import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = apiBaseUrl;
  bool _useAuth = true;
  String? _authToken;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _initializeAuthToken();
  }

  Future<void> _initializeAuthToken() async {
    _authToken = await _storage.read(key: 'auth_token');
  }

  Future<void> _ensureAuthToken() async {
    if (_useAuth && _authToken == null) {
      await _initializeAuthToken();
    }
  }

  void setAuthToken(String token) {
    _authToken = token;
    _storage.write(key: 'auth_token', value: token);
  }

  void enableAuth() {
    _useAuth = true;
  }

  void disableAuth() {
    _useAuth = false;
  }

  Future<http.Response> get(String endpoint) async {
    await _ensureAuthToken();
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (_useAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('GET Request: $url');
      print('Headers: $headers');
    }
    final response = await http.get(url, headers: headers);
    if (kDebugMode) {
      print('Response: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _ensureAuthToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_useAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('POST Request: $url');
      print('Headers: $headers');
      print('Body: ${body != null ? jsonEncode(body) : null}');
    }
    final response = await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (kDebugMode) {
      print('Response: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _ensureAuthToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_useAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('PUT Request: $url');
      print('Headers: $headers');
      print('Body: ${body != null ? jsonEncode(body) : null}');
    }
    final response = await http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (kDebugMode) {
      print('Response: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    await _ensureAuthToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_useAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('DELETE Request: $url');
      print('Headers: $headers');
    }
    final response = await http.delete(url, headers: headers);
    if (kDebugMode) {
      print('Response: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<String> showImage(String endpoint) async {
    await _ensureAuthToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_useAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }
}
