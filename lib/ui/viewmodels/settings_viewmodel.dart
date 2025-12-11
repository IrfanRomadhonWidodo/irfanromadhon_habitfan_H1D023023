import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyUserName = 'userName';
  static const String _keyIsDarkMode = 'isDarkMode';
  static const String _keyIsNotificationsEnabled = 'isNotificationsEnabled';

  Box? _box;
  String _userName = 'User';
  bool _isDarkMode = true;
  bool _isNotificationsEnabled = false;
  bool _isLoading = true;

  String get userName => _userName;
  bool get isDarkMode => _isDarkMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  bool get isLoading => _isLoading;

  SettingsViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _box = await Hive.openBox(_boxName);
      _userName = _box?.get(_keyUserName, defaultValue: 'User') ?? 'User';
      _isDarkMode = _box?.get(_keyIsDarkMode, defaultValue: true) ?? true;
      _isNotificationsEnabled = _box?.get(_keyIsNotificationsEnabled, defaultValue: false) ?? false;
    } catch (e) {
      print('Error initializing settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _box?.put(_keyUserName, name);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _box?.put(_keyIsDarkMode, isDark);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    _isNotificationsEnabled = isEnabled;
    await _box?.put(_keyIsNotificationsEnabled, isEnabled);
    notifyListeners();
  }
}
