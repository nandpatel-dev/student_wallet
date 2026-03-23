import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {

  // ── State ──────────────────────────────────────
  bool _isDarkMode = false;

  // ── Getters ────────────────────────────────────
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Brightness get brightness =>
      _isDarkMode ? Brightness.dark : Brightness.light;

  // ── Constructor — auto detect system theme ─────
  ThemeProvider() {
    _isDarkMode = _getSystemBrightness();
  }

  // ── Detect system dark/light mode ─────────────
  bool _getSystemBrightness() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  // ── Toggle Dark / Light ────────────────────────
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ── Set Specific Mode ──────────────────────────
  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
  }

  // ── Set from ThemeMode ─────────────────────────
  void setThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        setDarkMode(true);
        break;
      case ThemeMode.light:
        setDarkMode(false);
        break;
      case ThemeMode.system:
        setDarkMode(_getSystemBrightness());
        break;
    }
  }

  // ── Reset to System Default ────────────────────
  void resetToSystem() {
    setDarkMode(_getSystemBrightness());
  }
}
