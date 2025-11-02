// carga modelo, predicción y etiquetas
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class TranslationService {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    _interpreter = await Interpreter.fromAsset(
      'assets/model/sign_language_model.tflite',
    );
    _isModelLoaded = true;
  }

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
