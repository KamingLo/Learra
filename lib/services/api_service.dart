import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Pastikan variabel ini sesuai dengan nama di file .env kamu
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  // --- HELPER: MENYIAPKAN HEADERS ---
  Future<Map<String, String>> _getHeaders() async {
    // 1. Ambil instance SharedPreferences

    final prefs = await SharedPreferences.getInstance();

    // 2. Baca token (gunakan getString untuk SharedPrefs)
    String? token = prefs.getString('auth_token'); 

    // 3. Setup header dasar
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': _apiKey, // API Key dari .env
    };

    // 4. Jika token ada, tambahkan Bearer token
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // --- METHOD GET ---
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(); 

    try {
      final response = await http.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      rethrow; // Lempar error agar bisa ditangkap di UI (FutureBuilder/TryCatch)
    }
  }

  // --- METHOD POST ---
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.post(
        url, 
        headers: headers, 
        body: body != null ? jsonEncode(body) : null // Encode body ke JSON string
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // --- METHOD PUT ---
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.put(
        url, 
        headers: headers, 
        body: body != null ? jsonEncode(body) : null
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // --- METHOD DELETE ---
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.delete(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // --- HELPER: HANDLE RESPONSE ---
  dynamic _processResponse(http.Response response) {
    // Cek status code 200-299 (Sukses)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Jika body kosong, return null atau map kosong (tergantung API)
      if (response.body.isEmpty) return {};
      
      return jsonDecode(response.body);
    } else {
      // Gagal: Lempar exception dengan detail error
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}