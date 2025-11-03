import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

// A service class responsible for managing TensorFlow Lite model
// inference to translate detected hand landmarks into recognized
// letters or words.

// This service loads a pre-trained `.tflite` model from the app's assets
// and uses it to predict sign language gestures in real-time.

// Main Responsibilities:
// - Load and manage the TensorFlow Lite interpreter.
// - Perform predictions using input landmark data.
// - Map prediction indices to human-readable labels (letters or words).
class TranslationService {
  /// The TensorFlow Lite interpreter used for model inference.
  late Interpreter _interpreter;

  /// Tracks whether the model has already been loaded.
  bool _isModelLoaded = false;

  // Loads the TensorFlow Lite model from the app's assets.
  // Prevents redundant loading by checking the `_isModelLoaded` flag.
  // This method should be called before running predictions.
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    _interpreter = await Interpreter.fromAsset(
      'assets/model/sign_language_model.tflite',
    );
    _isModelLoaded = true;
  }

  // Maps a model prediction index to its corresponding label.
  // The labels represent letters or basic words recognized by the model.
  // Returns `"?"` if the index is out of range.
  String mapIndexToLabel(int index) {
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
      "GATO",
      "J",
      "K",
      "L",
    ];
    return (index >= 0 && index < labels.length) ? labels[index] : "?";
  }

  // Runs inference on the given input data (list of landmark coordinates)
  // and returns a prediction result.

  // The method:
  // 1. Converts the input landmarks into a tensor-friendly format.
  // 2. Executes the model using the TensorFlow Lite interpreter.
  // 3. Determines the most likely prediction and its confidence.

  // Returns a `Map` containing:
  // - `"label"` --> predicted letter/word
  // - `"confidence"` --> integer confidence percentage (0–100)
  Map<String, dynamic> predict(List<double> input) {
    var inputTensor = Float32List.fromList(input);
    var output = List.filled(11, 0.0).reshape([1, 11]);
    _interpreter.run(inputTensor, output);

    List<double> resultList = List<double>.from(output[0]);
    double maxValue = resultList.reduce((a, b) => a > b ? a : b);
    int predictedIndex = resultList.indexOf(maxValue);

    return {
      "label": mapIndexToLabel(predictedIndex),
      "confidence": (maxValue * 100).round(),
    };
  }
}
