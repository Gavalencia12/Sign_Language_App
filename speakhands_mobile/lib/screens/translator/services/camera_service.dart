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

  // Channel used to communicate with the native side (Android)
  // to request hand landmarks.
  static const platform = MethodChannel('com.speakhands/landmarks');

  // Initializes and starts the camera stream.
  // By default, this method selects the **first available camera**
  // and sets its resolution to medium. Audio is disabled to optimize
  // performance for hand recognition tasks.
  Future<void> startCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
    isActive = true;
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
