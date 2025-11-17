import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // Observable untuk tema mode
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  // Key untuk shared preferences
  static const String _themeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // Load tema dari shared preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool(_themeKey) ?? false;
      _isDarkMode.value = savedTheme;
      _updateTheme();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  // Toggle tema dark/light
  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _saveTheme();
    _updateTheme();
  }

  // Set tema secara langsung
  Future<void> setTheme(bool isDark) async {
    _isDarkMode.value = isDark;
    await _saveTheme();
    _updateTheme();
  }

  // Simpan tema ke shared preferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode.value);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  // Update tema di GetMaterialApp
  void _updateTheme() {
    Get.changeThemeMode(
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // Get current theme mode
  ThemeMode get themeMode => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}

