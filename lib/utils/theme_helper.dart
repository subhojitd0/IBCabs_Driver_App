import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier with WidgetsBindingObserver {
  bool _isDark = false;
  bool _userOverride = false; // 🔥 track if user changed manually

  bool get isDark => _isDark;

  ThemeService() {
    WidgetsBinding.instance.addObserver(this);
  }

  // 🔥 Load theme
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('isDarkMode')) {
      _isDark = prefs.getBool('isDarkMode') ?? false;
      _userOverride = true;
    } else {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;

      _isDark = brightness == Brightness.dark;
      _userOverride = false;
    }

    notifyListeners();
  }

  // 🔥 Toggle manually
  Future<void> toggleTheme(bool value) async {
    _isDark = value;
    _userOverride = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    print("Saved theme: $value"); // 🔥 debug
    notifyListeners();
  }

  // 🔥 LISTEN TO SYSTEM CHANGES
  @override
  void didChangePlatformBrightness() {
    if (_userOverride) return; // 👈 respect user choice

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    _isDark = brightness == Brightness.dark;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
