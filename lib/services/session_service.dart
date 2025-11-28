import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyRole = 'role';
  static const String _keyToken = 'token';
  static const String _keyId = 'id';
  static const String _keyName = 'name';

  // 1. Simpan Data Login (Role + Token JWT + ID + Name)
  static Future<void> saveSession(String role, String token, String id, String name) async {
    final prefs = await SharedPreferences.getInstance();

    const sessionDuration = Duration(hours: 1);

    final expireAt = DateTime.now().add(sessionDuration).millisecondsSinceEpoch;

    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyId, id);
    await prefs.setString(_keyName, name);

    await prefs.setInt("session_expire_at", expireAt);
  }

  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();

    final expireAt = prefs.getInt("session_expire_at");

    if (expireAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (now > expireAt) {
      // sesi sudah kadaluarsa → bersihkan
      await prefs.clear();
      return false;
    }

    return true;
  }


  // Update nama saja (misalnya setelah edit profile)
  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  // 2. Ambil Role (Return 'guest' jika null/belum login)
  static Future<String> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_keyRole);
    return role ?? 'guest'; // Default ke guest jika belum login
  }

  // 3. Ambil Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // 4. Ambil ID (BARU)
  static Future<String?> getCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyId);
  }

  // 5. Ambil Nama (BARU)
  static Future<String?> getCurrentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  // 6. Logout (Hapus semua)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}