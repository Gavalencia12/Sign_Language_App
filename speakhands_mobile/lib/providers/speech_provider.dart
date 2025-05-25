import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechProvider with ChangeNotifier {
  bool _enabled = false;

  bool get enabled => _enabled;

  SpeechProvider() {
    _loadSpeechPreference(); // Se carga al crear el Provider
  }

  void toggleSpeech(bool value) async {
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('speech_enabled', value);
  }

  Future<void> _loadSpeechPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('speech_enabled') ?? false;
    notifyListeners();
  }
}
