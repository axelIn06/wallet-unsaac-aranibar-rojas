import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  ThemePreferences(this._storage);

  static const key = 'theme_mode';
  final SharedPreferences _storage;

  ThemeMode loadMode() => switch (_storage.get(key)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> saveMode(ThemeMode mode) async {
    if (!await _storage.setString(key, mode.name)) {
      throw StateError('No se pudo guardar el modo del tema.');
    }
  }
}
