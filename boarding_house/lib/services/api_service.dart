import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan cookies secara lokal
import '../models/response_model.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  final Map<String, String> _cookies = {}; // Menyimpan cookies secara sementara

  // Simpan cookies ke SharedPreferences
  Future<void> _saveCookies(http.Response response) async {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('cookies', cookies);
      _cookies['Cookie'] =
          cookies; // Simpan cookies untuk permintaan selanjutnya
    }
  }

  // Ambil cookies dari SharedPreferences
  Future<void> _loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final cookies = prefs.getString('cookies');
    if (cookies != null) {
      _cookies['Cookie'] = cookies;
    }
  }

  void _logResponse(String endpoint, http.Response response) {
    if (kDebugMode) {
      print('Endpoint: $endpoint');
      print('Response Body: ${response.body}');
      print('Status Code: ${response.statusCode}');
    }
  }

  // GET Request
  Future<ResponseModel> get(String endpoint) async {
    await _loadCookies(); // Muat cookies sebelum permintaan
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _cookies,
      );
      _logResponse(endpoint, response);

      if (response.statusCode == 200) {
        return ResponseModel.fromJson(json.decode(response.body));
      } else {
        return ResponseModel(
          success: false,
          message: 'Error: ${response.statusCode}',
          status: 'error',
          data: json.decode(response.body)['data'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      return ResponseModel(
        success: false,
        message: 'Exception: $e',
        status: 'error',
        data: e.toString(),
      );
    }
  }

  // POST Request (Untuk login)
  Future<ResponseModel> post(String endpoint, Map<String, dynamic> body) async {
    await _loadCookies(); // Muat cookies sebelum permintaan
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          ..._cookies, // Tambahkan cookies jika ada
        },
        body: json.encode(body),
      );
      _logResponse(endpoint, response);

      // Simpan cookies setelah login berhasil
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveCookies(response);
        return ResponseModel.fromJson(json.decode(response.body));
      } else {
        return ResponseModel(
          success: false,
          message: 'Error: ${response.statusCode}',
          status: 'error',
          data: json.decode(response.body)['data'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      return ResponseModel(
        success: false,
        message: 'Exception: $e',
        status: 'error',
        data: e.toString(),
      );
    }
  }
}
