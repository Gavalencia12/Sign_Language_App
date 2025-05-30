import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text, {String? languageCode}) async {
    if (languageCode != null) {
      await _flutterTts.setLanguage(languageCode);
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
