import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'services/camera_service.dart';
import 'services/translation_service.dart';
import 'widgets/camera_preview_box.dart';
import 'widgets/translation_result_box.dart';
import 'widgets/translator_controls.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final CameraService _cameraService = CameraService();
  final TranslationService _translationService = TranslationService();
  final TextToSpeechService _ttsService = TextToSpeechService();

  bool _isDisposed = false;
  bool _isCameraActive = false;
  bool _canDetect = true;
  String _translationResult = "";
  Timer? _delayTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _translationService.loadModel();
    if (!_isDisposed) {
      setState(
        () =>
            _translationResult =
                AppLocalizations.of(context)!.waiting_prediction,
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _speakTranslatorIntro(),
      );
    }
  }

  Future<void> _speakTranslatorIntro() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    final loc = AppLocalizations.of(context)!;

    if (!speakOn || _isDisposed) return;

    await _ttsService.stop();
    await _ttsService.speak(loc.screen_intro);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_isDisposed) return;
    await _ttsService.speak(loc.subtitle_intro);
  }

  Future<void> _toggleCamera() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    final loc = AppLocalizations.of(context)!;

    if (_isCameraActive) {
      await _cameraService.stopCamera();
      _delayTimer?.cancel();
      _cooldownTimer?.cancel();
      if (!_isDisposed)
        setState(() {
          _isCameraActive = false;
          _translationResult = loc.waiting_prediction;
        });
      if (speakOn && !_isDisposed)
        await _ttsService.speak(loc.camera_toggle_off);
      _canDetect = true;
    } else {
      await _cameraService.startCamera();
      if (!_isDisposed) setState(() => _isCameraActive = true);
      if (speakOn && !_isDisposed)
        await _ttsService.speak(loc.camera_toggle_on);

      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (_isDisposed || !_cameraService.isActive) {
          timer.cancel();
        } else if (_canDetect) {
          await _processFrame();
        }
      });
    }
  }

  Future<void> _processFrame() async {
    final landmarks = await _cameraService.getLandmarks();
    if (landmarks == null || landmarks.length != 63) {
      if (!_isDisposed) setState(() => _translationResult = "");
      return;
    }

    _canDetect = false;
    _delayTimer = Timer(const Duration(seconds: 3), () async {
      final prediction = _translationService.predict(landmarks);
      final label = prediction["label"];
      final confidence = prediction["confidence"];
      final text = "Letra detectada: $label ($confidence%)";

      if (!_isDisposed) setState(() => _translationResult = text);

      if (confidence > 50 && !_isDisposed) {
        final speakOn =
            Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (speakOn) {
          await _ttsService.stop();
          await _ttsService.speak(text);
        }
      }

      _cooldownTimer = Timer(const Duration(seconds: 3), () {
        _canDetect = true;
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _delayTimer?.cancel();
    _cooldownTimer?.cancel();
    _ttsService.stop();
    _cameraService.stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: loc.translator_screen_title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                loc.let_your_hands_speak,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    CameraPreviewBox(
                      isCameraActive: _isCameraActive,
                      controller: _cameraService.controller,
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: FloatingActionButton.small(
                          backgroundColor:
                              _isCameraActive ? Colors.redAccent : Colors.teal,
                          heroTag: "camera_toggle_btn",
                          onPressed: _toggleCamera,
                          child: Icon(
                            _isCameraActive ? Icons.stop : Icons.videocam,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.translation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TranslationResultBox(text: _translationResult),
              const SizedBox(height: 16),
              TranslatorControls(
                onRefresh: () {
                  setState(() => _translationResult = loc.waiting_prediction);
                },
                onPause: () async {
                  if (_isCameraActive) await _processFrame();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
