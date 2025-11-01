// lib/widgets/recorder_button.dart
import 'package:flutter/material.dart';

class RecorderButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  RecorderButton({required this.isRecording, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isRecording ? Icons.stop : Icons.mic,
        size: 40.0,
        color: Colors.red,
      ),
      onPressed: onPressed,
    );
  }
}
