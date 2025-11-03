import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum that defines the available theme modes in the app.
// - [light] --> Light theme mode.
// - [dark] --> Dark theme mode.
// - [system] --> Uses the system-defined theme (follows device settings).
enum ThemeModeOption { light, dark, system }

// A provider responsible for managing the app’s theme mode (light, dark, or system)
// and persisting the user’s choice using [SharedPreferences].
// This class extends [ChangeNotifier], allowing widgets that depend on it
// to automatically rebuild when the theme changes.
class ThemeProvider extends ChangeNotifier {
  // Key used to store the theme mode preference in [SharedPreferences].
  static const _themeKey = 'theme_mode';

  // Holds the current selected theme mode option.
  ThemeModeOption _themeModeOption = ThemeModeOption.system;

  // Returns the current [ThemeModeOption].
  ThemeModeOption get themeModeOption => _themeModeOption;

  // Converts the internal [ThemeModeOption] into Flutter’s [ThemeMode],
  // which is directly used by the [MaterialApp].
  ThemeMode get themeMode {
    switch (_themeModeOption) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Loads the saved theme mode from [SharedPreferences].
  // If no value is found, the system default mode is used.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);

    if (saved != null) {
      try {
        _themeModeOption = ThemeModeOption.values.firstWhere(
          (e) => e.toString() == saved,
          orElse: () => ThemeModeOption.system,
        );
      } catch (_) {
        _themeModeOption = ThemeModeOption.system;
      }
    }
    // Notifies all listeners that the theme has changed.
    notifyListeners();
  }

  // Sets a new theme mode and saves it persistently using [SharedPreferences].
  // - [option] --> The theme mode selected by the user.
  Future<void> setThemeMode(ThemeModeOption option) async {
    _themeModeOption = option;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, option.toString());
  }
}
