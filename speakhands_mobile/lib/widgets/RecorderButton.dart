// widget será responsable de mostrar el botón para grabar o detener la grabación, y puede cambiar de estilo dependiendo del estado.

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
