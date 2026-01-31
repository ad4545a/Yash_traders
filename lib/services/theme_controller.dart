import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  
  factory ThemeController() {
    return _instance;
  }
  
  ThemeController._internal();
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
  
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
}