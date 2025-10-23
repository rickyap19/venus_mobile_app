import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyEmail = 'auth_email';
  static const String _keyFullName = 'auth_fullname';
  static const String _keyRole = 'auth_role';
  static const String _keyExpiresAt = 'auth_expires_at';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Simpan data login
  static Future<void> saveLoginData({
    required String token,
    required String email,
    required String fullName,
    required String role,
    required String expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyExpiresAt, expiresAt);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Get Email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Get Full Name
  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  // Get Role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // Get Expires At
  static Future<String?> getExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyExpiresAt);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) return false;

    // Check if token expired
    final expiresAt = prefs.getString(_keyExpiresAt);
    if (expiresAt != null) {
      final expiryDate = DateTime.parse(expiresAt);
      if (DateTime.now().isAfter(expiryDate)) {
        await logout();
        return false;
      }
    }

    return true;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyExpiresAt);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Get all user data
  static Future<Map<String, String?>> getUserData() async {
    return {
      'token': await getToken(),
      'email': await getEmail(),
      'fullName': await getFullName(),
      'role': await getRole(),
      'expiresAt': await getExpiresAt(),
    };
  }
}