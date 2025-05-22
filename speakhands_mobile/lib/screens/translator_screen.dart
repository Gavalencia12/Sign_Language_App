import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';

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

  String _translationResult = "Waiting for prediction...";

  static const platform = MethodChannel('com.speakhands/landmarks');

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/sign_language_model.tflite');
      setState(() => _isModelLoaded = true);
    } catch (e) {
      print("Error al cargar el modelo: $e");
    }
  }

  Future<void> _toggleCamera() async {
    if (_isCameraActive) {
      await _cameraController?.dispose();
      setState(() {
        _cameraController = null;
        _isCameraActive = false;
      });
    } else {
      try {
        final cameras = await availableCameras();
        final camera = cameras.first;
        _cameraController = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
        setState(() {
          _isCameraActive = true;
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
        await _makePrediction(landmarks);
      } else {
        print("Landmarks inválidos");
      }
    } on PlatformException catch (e) {
      print("Error al obtener landmarks nativos: ${e.message}");
    }
  }

  Future<void> _makePrediction(List<double> input) async {
    try {
      var inputTensor = Float32List.fromList(input);
      var output = List.filled(8, 0.0).reshape([1, 8]);

      _interpreter.run(inputTensor, output);

      List<double> resultList = List<double>.from(output[0]);
      double maxValue = resultList.reduce((a, b) => a > b ? a : b);
      int predictedIndex = resultList.indexOf(maxValue);

      String predictedLabel = "Letra ${String.fromCharCode(65 + predictedIndex)}";

      setState(() {
        _translationResult = "Letra detectada: $predictedLabel";
      });
    } catch (e) {
      print("Error al hacer la predicción: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final appBarColor = themeProvider.isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A); 

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text("TRANSLATE", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Speak", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Text("Hands", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        backgroundColor: backgroundColor, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Let your hands speak",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
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
                        setState(() {
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
                ),
              ),
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
