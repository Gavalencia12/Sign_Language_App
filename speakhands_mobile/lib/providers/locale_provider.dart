import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String prefKey = 'selectedLocale';

  Locale _locale = const Locale('es'); // idioma por defecto
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _isLoaded;

  LocaleProvider() {
    _loadLocale();
  }

  // Carga el idioma guardado al iniciar el provider
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(prefKey);

    if (localeCode != null &&
        L10n.all.any((l) => l.languageCode == localeCode)) {
      _locale = Locale(localeCode);
    }

    _isLoaded = true;
    // 🔹 Importante: notificar después de cargar
    notifyListeners();
  }

  // Cambiar idioma y guardar en SharedPreferences
  Future<void> setLocale(Locale locale) async {
    // 🔹 Compara correctamente por languageCode
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, locale.languageCode);
  }

  /// Restablece el idioma por defecto
  Future<void> clearLocale() async {
    _locale = const Locale('es');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefKey);
  }
}

class L10n {
  static final all = [const Locale('en'), const Locale('es')];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return '';
    }
  }
}
