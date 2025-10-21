/* import 'package:speech_to_text/speech_to_text.dart' as stt; */
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init({String locale = 'es-MX'}) async {
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  // Firma compatible: sigue aceptando solo 'text'. (Puedes dejar también languageCode opcional si no rompe.)
  Future<void> speak(String text, {String? languageCode}) async {
    if (languageCode != null) {
      await _tts.setLanguage(languageCode);
    }
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  void dispose() {
    _tts.stop();
  }
}
