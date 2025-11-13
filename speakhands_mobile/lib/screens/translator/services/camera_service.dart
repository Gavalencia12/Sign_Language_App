import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// A service responsible for managing the device camera lifecycle
// and communicating with native platform code to obtain hand landmarks.

// This service is primarily used in the *interpreter* or *translator*
// modules of the app to capture frames and extract key hand points
// (landmarks) through a native method channel.

// Key Responsibilities:
// - Initialize and control the camera stream.
// - Dispose of resources safely.
// - Communicate with the native layer (via `MethodChannel`)
//   to retrieve landmarks detected by platform-specific ML models.
class CameraService {
  // Controls the device camera and provides video feed access.
  CameraController? controller;
  // Indicates whether the camera is currently active.
  bool isActive = false;
  // Tracks whether the controller has been disposed.
  bool isDisposed = false;

  // List of available cameras on the device.
  List<CameraDescription> _cameras = [];

  // Currently selected camera (e.g., front or back).
  CameraDescription? _currentCamera;

  // Maximum and minimum zoom levels supported by the camera.
  double _maxZoom = 1.0;
  double _minZoom = 1.0;

  // Getters for camera properties.
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;

  // Channel used to communicate with the native side (Android)
  // to request hand landmarks.
  static const platform = MethodChannel('com.speakhands/landmarks');

  // Initializes and starts the camera stream.
  // By default, this method selects the **first available camera**
  // and sets its resolution to medium. Audio is disabled to optimize
  // performance for hand recognition tasks.
  Future<void> startCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    // Select the rear camera
    _currentCamera = _cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    await _initializeCamera(_currentCamera!);
  }


  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    // If there is already a controller, we stop it first
    if (controller != null) {
      await controller?.dispose();
    }

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    // Saves the zoom levels of the current camera
    _minZoom = await controller!.getMinZoomLevel();
    _maxZoom = await controller!.getMaxZoomLevel();

    _currentCamera = cameraDescription;
    isActive = true;
  }

  // Switch between the front and rear cameras.
  Future<void> flipCamera() async {
    if (_cameras.isEmpty || !isActive) return;

    // Determine the opposite direction
    final currentDirection = _currentCamera!.lensDirection;
    final newDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    // Search the new Camera
    CameraDescription newCamera = _cameras.firstWhere(
      (cam) => cam.lensDirection == newDirection,
      orElse: () => _cameras.first,
    );

    await _initializeCamera(newCamera);
  }

  // Sets the zoom level, ensuring it is within limits.
  Future<void> setZoom(double zoom) async {
    if (controller == null || !isActive) return;
    // Holds the value between the minimum and maximum
    double clampedZoom = zoom.clamp(_minZoom, _maxZoom);
    await controller!.setZoomLevel(clampedZoom);
  }

  // Stops the camera and releases all associated resources.
  // Should always be called in the `dispose()` method of the parent
  // widget or when leaving the interpreter/translator screen to
  // prevent memory leaks or crashes.
  Future<void> stopCamera() async {
    await controller?.dispose();
    controller = null;
    isActive = false;
  }

  // Requests hand landmarks from the native side (via `MethodChannel`).
  // The landmarks are typically a list of floating-point values representing
  // x/y/z coordinates for detected hand keypoints.
  // Returns `null` if the call fails or the platform does not respond.
  Future<List<double>?> getLandmarks() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getLandmarks');
      return result.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      print("Error al obtener landmarks: $e");
      return null;
    }
  }
}
