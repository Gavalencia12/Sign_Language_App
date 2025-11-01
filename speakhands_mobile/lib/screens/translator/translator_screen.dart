import 'dart:async'; // Import necesario para Timer
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  CameraController? _cameraController;
  bool _isCameraActive = false;
  final TextToSpeechService ttsService = TextToSpeechService();
  bool _isDisposed = false;

  String _translationResult = "";
  String? _lastSpokenLabel;

  Timer? _periodicTimer;

  // Estados para controlar la detección y el habla
  bool _canDetect = true;  // Controla si puede procesar landmarks
  Timer? _delayTimer;      // Timer para los 3 segundos antes de hablar
  Timer? _cooldownTimer;   // Timer para los 3 segundos de espera post-audio

  static const platform = MethodChannel('com.speakhands/landmarks');

  @override
  void initState() {
    super.initState();
    _loadModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakTranslatorIntro();
    });
  }

  Future<void> _speakTranslatorIntro() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    if (!speakOn || _isDisposed) return;

    final loc = AppLocalizations.of(context)!;

    await ttsService.stop();
    if (_isDisposed) return;
    await ttsService.speak(loc.screen_intro);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_isDisposed) return;
    await ttsService.speak(loc.subtitle_intro);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_isDisposed) return;
    await ttsService.speak(loc.camera_toggle_off);
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/sign_language_model.tflite');
      if (!_isDisposed) setState(() {
        _isModelLoaded = true;
        _translationResult = AppLocalizations.of(context)!.waiting_prediction;
      });
    } catch (e) {
      print("Error al cargar el modelo: $e");
    }
  }

  Future<void> _toggleCamera() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    final loc = AppLocalizations.of(context)!;

    if (_isCameraActive) {
      await _cameraController?.dispose();
      _periodicTimer?.cancel();
      _delayTimer?.cancel();
      _cooldownTimer?.cancel();
      if (!_isDisposed) setState(() {
        _cameraController = null;
        _isCameraActive = false;
        _translationResult = loc.waiting_prediction;
      });
      if (speakOn && !_isDisposed) await ttsService.speak(loc.camera_toggle_off);
      _canDetect = true;  // Reset estado
    } else {
      try {
        final cameras = await availableCameras();
        final camera = cameras.first;
        _cameraController = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
        if (!_isDisposed) setState(() {
          _isCameraActive = true;
        });
        if (speakOn && !_isDisposed) await ttsService.speak(loc.camera_toggle_on);

        _periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
          if (!_isDisposed && _isCameraActive && _canDetect) {
            _getNativeLandmarks();
          } else {
            timer.cancel();
          }
        });
      } catch (e) {
        print("Error al iniciar cámara: $e");
      }
    }
  }

  Future<void> _getNativeLandmarks() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getLandmarks');
      final landmarks = result.map((e) => (e as num).toDouble()).toList();

      if (landmarks.length == 63) {
        // Si está permitido detectar
        if (_canDetect) {
          _canDetect = false;  // Bloquea detección
          // Espera 3 segundos antes de procesar (simula "ver puntos por 3s")
          _delayTimer = Timer(const Duration(seconds: 3), () async {
            await _makePrediction(landmarks);
            // Luego del habla, espera 3 segundos para permitir nueva detección
            _cooldownTimer = Timer(const Duration(seconds: 3), () {
              _canDetect = true;
            });
          });
        }
      } else {
        if (!_isDisposed) {
          setState(() {
            _translationResult = ""; // No mostrar texto si no hay manos
          });
        }
        // Aquí puedes agregar lógica si quieres aviso por ausencia mano
      }
    } on PlatformException catch (e) {
      print("Error al obtener landmarks nativos: ${e.message}");
    }
  }

  String _mapIndexToLabel(int index) {
    const labels = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "M",
      "GATO", // palabra completa
      "J",
      "K",
      "L"
    ];

    if (index >= 0 && index < labels.length) {
      return labels[index];
    }
    return "?";
  }

  Future<void> _makePrediction(List<double> input) async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;

    try {
      var inputTensor = Float32List.fromList(input);
      var output = List.filled(11, 0.0).reshape([1, 11]);

      _interpreter.run(inputTensor, output);

      List<double> resultList = List<double>.from(output[0]);
      double maxValue = resultList.reduce((a, b) => a > b ? a : b);
      int predictedIndex = resultList.indexOf(maxValue);

      String predictedLabel = _mapIndexToLabel(predictedIndex);
      int confidencePercent = (maxValue * 100).round();

      String displayText = "Letra detectada: $predictedLabel ($confidencePercent%)";

      if (!_isDisposed) {
        setState(() {
          _translationResult = displayText;
        });
      }

      // Hablar siempre que haya detección válida (confianza > 50)
      if (speakOn && !_isDisposed && confidencePercent > 50) {
        _lastSpokenLabel = predictedLabel;
        await ttsService.stop();
        if (!_isDisposed) await ttsService.speak(displayText);
      }
    } catch (e) {
      print("Error al hacer la predicción: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _periodicTimer?.cancel();
    _delayTimer?.cancel();
    _cooldownTimer?.cancel();
    _cameraController?.dispose();
    ttsService.stop();
    super.dispose();
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () async {
          final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
          onPressed();
          if (speakOn && !_isDisposed) {
            await ttsService.stop();
            final loc = AppLocalizations.of(context)!;
            if (icon == Icons.refresh) {
              await ttsService.speak(loc.reset_message);
            } else if (icon == Icons.pause) {
              await ttsService.speak(loc.pause_explanation);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: loc.translator_screen_title),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isPortrait
                  ? Column(children: _buildContent(context, themeProvider, loc))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: _buildCameraPreview(context, loc),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildContent(context, themeProvider, loc, excludeCamera: true),
                          ),
                        )
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, ThemeProvider themeProvider, AppLocalizations loc,
      {bool excludeCamera = false}) {
    return [
      if (!excludeCamera) ...[
        Text(
          loc.let_your_hands_speak,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: _buildCameraPreview(context, loc),
        ),
        const SizedBox(height: 16),
      ],
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          loc.translation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _translationResult,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  Widget _buildCameraPreview(BuildContext context, AppLocalizations loc) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: Center(
            child: _isCameraActive && _cameraController != null && _cameraController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : Text(loc.camera_not_active),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: _circleButton(
            _isCameraActive ? Icons.stop : Icons.videocam,
            Colors.red,
            _toggleCamera,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _circleButton(Icons.refresh, Colors.teal, () {
            if (!_isDisposed) setState(() {
              _translationResult = AppLocalizations.of(context)!.waiting_prediction;
            });
          }),
        ),
        Positioned(
          bottom: 10,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: _circleButton(Icons.pause, Colors.blue, () async {
            if (_isCameraActive) await _getNativeLandmarks();
          }),
        ),
      ],
    );
  }
}
