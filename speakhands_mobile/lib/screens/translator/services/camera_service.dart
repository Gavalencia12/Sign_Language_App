import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class CameraService {
  CameraController? controller;
  bool isActive = false;
  bool isDisposed = false;
  static const platform = MethodChannel('com.speakhands/landmarks');

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

  Future<void> stopCamera() async {
    await controller?.dispose();
    controller = null;
    isActive = false;
  }

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
