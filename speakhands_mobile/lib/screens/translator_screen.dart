import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/data/speech_texts.dart';
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

  String _translationResult = "Waiting for prediction...";

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

    await ttsService.stop();
    if (_isDisposed) return;
    await ttsService.speak(TranslatorSpeechTexts.screenTitle);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_isDisposed) return;
    await ttsService.speak(TranslatorSpeechTexts.subtitle);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_isDisposed) return;
    await ttsService.speak(TranslatorSpeechTexts.cameraOff);
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/sign_language_model.tflite');
      if (!_isDisposed) setState(() => _isModelLoaded = true);
    } catch (e) {
      print("Error al cargar el modelo: $e");
    }
  }

  Future<void> _toggleCamera() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;

    if (_isCameraActive) {
      await _cameraController?.dispose();
      if (!_isDisposed) setState(() {
        _cameraController = null;
        _isCameraActive = false;
      });
      if (speakOn && !_isDisposed) await ttsService.speak(TranslatorSpeechTexts.cameraToggleOff);
    } else {
      try {
        final cameras = await availableCameras();
        final camera = cameras.first;
        _cameraController = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
        if (!_isDisposed) setState(() {
          _isCameraActive = true;
        });
        if (speakOn && !_isDisposed) await ttsService.speak(TranslatorSpeechTexts.cameraToggleOn);
      } catch (e) {
        print("Error al iniciar cámara: $e");
      }
    }
  }

  Future<void> _getNativeLandmarks() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    try {
      final List<dynamic> result = await platform.invokeMethod('getLandmarks');
      final landmarks = result.map((e) => (e as num).toDouble()).toList();
      if (landmarks.length == 63) {
        await _makePrediction(landmarks);
      } else {
        print("Landmarks inválidos");
        if (speakOn && !_isDisposed) await ttsService.speak(TranslatorSpeechTexts.noHandDetected);
      }
    } on PlatformException catch (e) {
      print("Error al obtener landmarks nativos: ${e.message}");
    }
  }

  Future<void> _makePrediction(List<double> input) async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    try {
      var inputTensor = Float32List.fromList(input);
      var output = List.filled(8, 0.0).reshape([1, 8]);

      _interpreter.run(inputTensor, output);

      List<double> resultList = List<double>.from(output[0]);
      double maxValue = resultList.reduce((a, b) => a > b ? a : b);
      int predictedIndex = resultList.indexOf(maxValue);

      String letter = String.fromCharCode(65 + predictedIndex);
      String predictedLabel = "Letra $letter";

      if (!_isDisposed) {
        setState(() {
          _translationResult = "Letra detectada: $predictedLabel";
        });
      }

      if (speakOn && !_isDisposed) {
        await ttsService.stop();
        if (!_isDisposed) await ttsService.speak(TranslatorSpeechTexts.detectedLetter(letter));
      }
    } catch (e) {
      print("Error al hacer la predicción: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
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
            if (icon == Icons.refresh) {
              await ttsService.speak(TranslatorSpeechTexts.resetMessage);
            } else if (icon == Icons.pause) {
              await ttsService.speak(TranslatorSpeechTexts.pauseExplanation);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "TRANSLATE"),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isPortrait
                  ? Column(children: _buildContent(context, themeProvider))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: _buildCameraPreview(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildContent(context, themeProvider, excludeCamera: true),
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

  List<Widget> _buildContent(BuildContext context, ThemeProvider themeProvider,
      {bool excludeCamera = false}) {
    return [
      if (!excludeCamera) ...[
        const Text(
          "Let your hands speak",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: _buildCameraPreview(context),
        ),
        const SizedBox(height: 16),
      ],
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Translation:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? AppTheme.darkSecondary
              : AppTheme.lightSecondary,
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

  Widget _buildCameraPreview(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: Center(
            child: _isCameraActive &&
                    _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : const Text("Cámara no activa"),
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
              _translationResult = "Waiting for prediction...";
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
