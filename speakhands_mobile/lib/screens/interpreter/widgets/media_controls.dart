import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/speech_io_service.dart'; // Importa el servicio de voz que usas


// Widget para los controles de medios
class MediaControls extends StatelessWidget {
  final bool isListening;
  final Function startStt;
  final Function stopStt;
  final Function speakText;
  final Function showText;
  final String interpretedText;
  final int charLimit;

  const MediaControls({
    Key? key,
    required this.isListening,
    required this.startStt,
    required this.stopStt,
    required this.speakText,
    required this.showText,
    required this.interpretedText,
    required this.charLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mic <-> Stop
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: isListening
              ? _stopButton(stopStt)
              : _startListeningButton(startStt),
        ),

        // Text-to-Speech (TTS)
        IconButton(
          tooltip: 'Speak Text',
          icon: const Icon(Icons.volume_up),
          onPressed: interpretedText.isEmpty
              ? null
              : () => speakText(interpretedText),
        ),

        // Show Text
        IconButton(
          tooltip: 'Show Text',
          icon: const Icon(Icons.visibility),
          onPressed: () => showText(interpretedText),
        ),
        
        const Spacer(),

        // Character counter
        Text(
          '${interpretedText.length} / $charLimit',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _startListeningButton(Function startStt) {
    return IconButton(
      icon: const Icon(Icons.mic),
      onPressed: () => startStt(),
    );
  }

  Widget _stopButton(Function stopStt) {
    return IconButton(
      icon: const Icon(Icons.stop_rounded),
      onPressed: () => stopStt(),
    );
  }
}
