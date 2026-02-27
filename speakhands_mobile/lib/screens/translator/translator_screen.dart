import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'services/camera_service.dart';
import 'services/translation_service.dart';
import 'widgets/camera_preview_box.dart';
import 'widgets/translation_result_box.dart';
import 'widgets/translator_controls.dart';
import 'package:speakhands_mobile/widgets/draggable_fab.dart';
import 'package:speakhands_mobile/screens/translator/widgets/carrusel_modal.dart';

// The main screen responsible for real-time sign language translation.

// This screen integrates camera input, a TensorFlow Lite model for prediction,
// and optional text-to-speech feedback. It is the centerpiece of the
// SpeakHands application, enabling users to “translate” hand gestures into text.

// Features:
// - Real-time camera feed handled by [CameraService].
// - AI model inference handled by [TranslationService].
// - Optional audio feedback through [TextToSpeechService].
// - Interactive controls to pause, refresh, or toggle the camera.
// - Dynamic localization via [AppLocalizations].
class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {

  // --- Services ---
  final CameraService _cameraService = CameraService();
  final TranslationService _translationService = TranslationService();
  final TextToSpeechService _ttsService = TextToSpeechService();

  // --- UI and logic states ---
  bool _isDisposed = false;
  bool _isCameraActive = false;
  bool _canDetect = true;
  String _translationResult = "";
  Timer? _delayTimer;
  Timer? _cooldownTimer;

  bool _isPaused = false;

  // --- Zoom control states ---
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  // Initializes the ML model and gives voice feedback once ready.
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

  void _CarouselModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CarouselModal(), 
    );
  }

  // Provides an introductory message using Text-to-Speech when the screen starts.
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

  // Toggles the camera state between active and inactive.
  // When active, it periodically captures frames and processes them.
  Future<void> _toggleCamera() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    final loc = AppLocalizations.of(context)!;

    if (_isCameraActive) {

      // Stop camera and timers
      await _cameraService.stopCamera();
      _delayTimer?.cancel();
      _cooldownTimer?.cancel();
      if (!_isDisposed)
        setState(() {
          _isCameraActive = false;
          _translationResult = loc.waiting_prediction;
          _isPaused = false;
        });
      if (speakOn && !_isDisposed)
        await _ttsService.speak(loc.camera_toggle_off);
      _canDetect = true;
    } else {

      // Start camera and begin frame detection loop
      await _cameraService.startCamera();
      
      // Reset zoom levels
      _currentZoomLevel = 1.0;
      _baseZoomLevel = 1.0;

      if (!_isDisposed) setState(() => _isCameraActive = true);
      if (speakOn && !_isDisposed)
        await _ttsService.speak(loc.camera_toggle_on);

      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (_isDisposed || !_cameraService.isActive) {
          timer.cancel();
        } else if (_canDetect && !_isPaused) { 
          await _processFrame();
        }
      });
    }
  }

  // Flips the camera between front and back.
  // Resets zoom levels after flipping.
  Future<void> _flipCameraAndUpdate() async {
    if (!_isCameraActive) return; 
    
    await _cameraService.flipCamera();
    
    // Resets zoom levels on rotation
    _currentZoomLevel = 1.0;
    _baseZoomLevel = 1.0;
    
    if (!_isDisposed) {
      setState(() {});
    }
  }

  // Processes a single camera frame by:
  // 1. Extracting hand landmarks.
  // 2. Running inference through the model.
  // 3. Updating the UI and providing optional speech output.
  Future<void> _processFrame() async {
    // If paused, skip processing
    if (_isPaused) return;

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

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double screenPadding = 16.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: CustomAppBar(title: loc.translator_screen_title),
      body:LayoutBuilder( 
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(screenPadding),
            child: Stack(
                  children: [
                    Column(
                      children: [

                        // --- Header ---
                        Text(
                          loc.let_your_hands_speak,
                          style: AppTextStyles.textTitle.copyWith(
                                color: AppColors.text(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // --- Camera preview section ---
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onScaleStart: (details) {
                              //save the base zoom level
                              _baseZoomLevel = _currentZoomLevel;
                            },
                            onScaleUpdate: (details) {
                              if (_cameraService.controller == null || !_isCameraActive) return;
                              
                              // Calculate the new zoom level
                              _currentZoomLevel = (_baseZoomLevel * details.scale)
                                  .clamp(
                                    _cameraService.minZoom,
                                    _cameraService.maxZoom,
                                  );
                              
                              //apply the zoom level to the camera
                              _cameraService.setZoom(_currentZoomLevel);
                            },
                            child: Stack(
                              children: [
                                CameraPreviewBox(
                                  isCameraActive: _isCameraActive,
                                  controller: _cameraService.controller,
                                ),
                               //buttons control
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Row(
                                    children: [
                                      // Botón 1: Toggle Cámara
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.surface(context),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.text(context).withOpacity(0.15),
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: FloatingActionButton.small(
                                          backgroundColor:
                                              _isCameraActive ? AppColors.error(context) : AppColors.primary(context),
                                          heroTag: "camera_toggle_btn",
                                          onPressed: _toggleCamera,
                                          child: Icon(
                                            _isCameraActive
                                                ? Icons.stop_rounded
                                                : Icons.videocam_rounded,
                                            color: AppColors.onPrimary(context),
                                          ),
                                        ),
                                      ),

                                      if (_isCameraActive)
                                              const SizedBox(width: 8),
                                      // botón 2: Flip Cámara
                                      if (_isCameraActive)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.surface(context),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.text(context).withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: FloatingActionButton.small(
                                            backgroundColor: AppColors.surface(context),
                                            heroTag: "camera_flip_btn",
                                            onPressed: _flipCameraAndUpdate,
                                            child: Icon(
                                              Icons.flip_camera_ios_rounded,
                                              color: AppColors.primary(context),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Translation output section ---
                        Text(
                          loc.translation,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.text(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        const SizedBox(height: 8),

                        // --- Bottom controls ---
                        TranslationResultBox(text: _translationResult),

                        const SizedBox(height: 16),

                        // Controls
                        TranslatorControls(
                          onRefresh: () {
                            setState(() {
                              _isPaused = false; // Resume if paused
                              _translationResult = loc.waiting_prediction;
                            });
                          },
                          onPause: () {
                            if (!_isCameraActive) return; 
                            
                            setState(() {
                              _isPaused = true; //pause detection
                              _translationResult = loc.predictions_paused; 
                            });
                            
                            //Cancel timers
                            _delayTimer?.cancel();
                            _cooldownTimer?.cancel();
                            _canDetect = true;
                          },
                        ),
                      ],
                    ),
                  DraggableFAB(
                    storageKey: 'translator_screen_fab_position',
                    initialTop: 320.0,
                    initialLeft: 277.0,
                    constraints: constraints, 
                    onPressed: _CarouselModal,
                  ),  
                ],
            ),
          );
        },
      )
    );
  }
}
