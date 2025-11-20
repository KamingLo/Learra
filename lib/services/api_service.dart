import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  // --- HELPER: MENYIAPKAN HEADERS ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    // --- PERBAIKAN DI SINI ---
    // Gunakan key 'token' (sesuai isi variabel _keyToken di SessionService), 
    // JANGAN gunakan string '_keyToken' secara literal.
    String? token = prefs.getString('token'); 

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': _apiKey,
    };

    // Jika token ada, otomatis pasang Bearer Token
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // --- METHOD GET ---
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(); // Header (auth) otomatis masuk sini

    try {
      final response = await http.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      rethrow;
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
        body: body != null ? jsonEncode(body) : null
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // --- METHOD PUT (EDIT) ---
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(); // Token otomatis masuk

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

  // --- METHOD DELETE (HAPUS) ---
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(); // Token otomatis masuk

    try {
      final response = await http.delete(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // --- HELPER: HANDLE RESPONSE ---
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}