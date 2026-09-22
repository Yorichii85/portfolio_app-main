import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _userName = "Student";
  ThemeMode _themeMode = ThemeMode.light;

  String get userName => _userName;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void updateName(String newName) {
    if (newName.trim().isEmpty) return;
    _userName = newName.trim();
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}