import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechIOService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool get sttReady => _speech.isAvailable;
  bool get isListening => _speech.isListening;

  Future<void> init({required String sttLocale, required String ttsLocale}) async {
    await _speech.initialize(onStatus: (status) => print('STT Status: $status'));
    await _flutterTts.setLanguage(ttsLocale);
  }

  Future<void> startListening({required String localeId, required Function(String, bool) onResult}) async {
    await _speech.listen(onResult: (result) {
      onResult(result.recognizedWords, result.finalResult);
    });
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Método para detener la síntesis de voz (stop speaking)
  Future<void> stopSpeak() async {
    await _flutterTts.stop();
  }

  // Método para cancelar la escucha de voz (cancel listening)
  Future<void> cancelListening() async {
    await _speech.stop();
  }

  void dispose() {
    _speech.stop();
    _flutterTts.stop();
  }
}
