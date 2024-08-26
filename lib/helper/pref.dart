import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Pref {
  static late Box _box;

  static Future<void> initialize() async {
    // Initialize Hive and the box
    Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
    _box = await Hive.box(name: 'myData'); // Ensure the box is opened correctly
  }

  static bool get showOnboarding => _box.get('showOnboarding', defaultValue: true);
  static set showOnboarding(bool v) => _box.put('showOnboarding', v);

  static bool get isDarkMode => _box.get('isDarkMode') ?? false;
  static set isDarkMode(bool v) => _box.put('isDarkMode', v);

  static ThemeMode defaultTheme() {
    final data = _box.get('isDarkMode');
    log('data: $data');
    if (data == null) return ThemeMode.system;
    if (data == true) return ThemeMode.dark;
    return ThemeMode.light;
  }

  // Method to mark onboarding as completed
  static void setOnboardingCompleted() {
    _box.put('showOnboarding', false); // Update the value to false when onboarding is completed
  }
}
