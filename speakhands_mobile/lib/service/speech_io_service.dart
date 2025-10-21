import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio unificado de **entrada de voz (STT)** y **salida de voz (TTS)**.
/// - STT: usa el plugin `speech_to_text` para convertir voz a texto.
/// - TTS: usa el plugin `flutter_tts` para leer texto en voz alta.
///
/// Flujo típico de uso:
///  1) Llamar a [startListening] para comenzar a dictar.
///  2) Llamar a [stopListening] para detener el dictado.
///  3) Llamar a [speak] para leer texto en voz alta cuando lo necesites.
///  4) Llamar a [dispose] cuando ya no uses el servicio (ej. en `dispose` del widget).

class SpeechIOService {
  // --- Dependencias internas del servicio ---
  final stt.SpeechToText _stt = stt.SpeechToText(); // Speech To Text
  final FlutterTts _tts = FlutterTts();             // Text To Speech

  // Estado de inicialización del STT.
  bool _sttReady = false;

  /// `true` si el STT ya fue inicializado correctamente.
  bool get sttReady => _sttReady;

  /// `true` si el micrófono está escuchando actualmente.
  bool get isListening => _stt.isListening;

  /// Inicializa STT y TTS.
  /// [sttLocale] y [ttsLocale] definen la **localidad/idioma** a usar.
  Future<void> init({
    String sttLocale = 'es-MX', 
    String ttsLocale = 'es-MX'
  }) async {
    // Inicializa Speech-To-Text y guarda si quedó listo.
    _sttReady = await _stt.initialize(
      onStatus: (s) => print('STT status: $s'),   // útil para depurar cambios de estado
      onError: (e) => print('STT error: $e'),     // loguea errores de STT
    );

    // Configura Text-To-Speech para Android/iOS.
    await _tts.setLanguage(ttsLocale);   // idioma de salida (TTS)
    await _tts.setSpeechRate(0.5);       // velocidad 0.0–1.0 (0.5 ≈ natural)
    await _tts.setVolume(1.0);           // volumen 0.0-1.0
    await _tts.setPitch(1.0);            // tono 0.5–2.0 (1.0 = normal)
    await _tts.awaitSpeakCompletion(true); // para saber cuándo termina
  }

  /// Comienza a escuchar el micrófono y convertir voz a texto.
  /// - [localeId]: idioma del reconocimiento (por defecto `'es-MX'`).
  /// - [onResult]: callback que recibe el **texto** reconocido y un flag [isFinal]
  ///   indicando si es resultado **final** (`true`) o **parcial** (`false`).
  /// Si el STT no está listo (no se llamó a [init] o falló), no hace nada.
  Future<void> startListening({
    String localeId = 'es-MX',
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_sttReady) return;
    await _stt.listen(
      localeId: localeId,
      partialResults: true,     // reporta resultados parciales
      cancelOnError: true,      // cancela la sesión en error
      onResult: (res) => onResult(
        res.recognizedWords,    // texto reconocido
        res.finalResult),       // resultado final
    );
  }

  /// Detiene el reconocimiento de voz, manteniendo el STT listo para otra sesión.
  Future<void> stopListening() => _stt.stop();

  /// Cancela por completo la sesión de STT en curso.
  /// Útil si quieres descartar la sesión actual (por error, navegación, etc.).
  Future<void> cancelListening() => _stt.cancel();

  /// Lee en voz alta el [text] recibido.
  /// Si [languageCode] viene distinto de `null` y no vacío, se usa ese idioma
  Future<void> speak(String text, {String? languageCode}) async {
  if (languageCode != null && languageCode.isNotEmpty) {
    await _tts.setLanguage(languageCode); // cambia idioma puntualmente
  }
  await _tts.stop();    // corta cualquier lectura previa
  await _tts.speak(text);
}

  /// Detiene inmediatamente cualquier lectura de TTS.
  Future<void> stopSpeak() => _tts.stop();

  /// Libera recursos cuando ya no se necesite el servicio.
  void dispose() {
    _stt.cancel();
    _tts.stop();
  }
}
