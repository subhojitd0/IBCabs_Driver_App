import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String isLoggedInKey = "isLoggedIn";
  static const String usernameKey = "username";
  static const String drivernameKey = "drivername";

  // Save login
  static Future<void> saveLogin(String username, String drivername) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(usernameKey, username);
    await prefs.setString(drivernameKey, drivername);
  }

  // Check login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  // Get username
  static Future<Map<String, String?>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "username": prefs.getString(usernameKey),
      "drivername": prefs.getString(drivernameKey),
    };
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
