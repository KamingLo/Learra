import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyRole = 'role';
  static const String _keyToken = 'token';

  // 1. Simpan Data Login (Role + Token JWT)
  static Future<void> saveSession(String role, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyToken, token); // Token tersimpan aman di sini
  }

  // 2. Ambil Role (Return 'guest' jika null/belum login)
  static Future<String> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_keyRole);
    return role ?? 'guest'; // Default ke guest jika belum login
  }

  // 3. Ambil Token (Untuk dipasang di Header HTTP Request nanti)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // 4. Logout (Hapus semua)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}