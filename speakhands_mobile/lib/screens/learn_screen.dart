import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/data/speech_texts.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextToSpeechService ttsService = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakText());
  }

  Future<void> _speakText() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    if (speakOn) {
      await ttsService.stop();
      await ttsService.speak(LearnSpeechTexts.intro);
    }
  }

  @override
  void dispose() {
    ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "LEARNING"),
      body: Column(
        children: [
          const Text('Learn Screen'),
          SwitchListTile(
            title: const Text("Lectura por voz"),
            value: speechProvider.enabled,
            onChanged: (value) => speechProvider.toggleSpeech(value),
          ),
        ],
      ),
    );
  }
}
