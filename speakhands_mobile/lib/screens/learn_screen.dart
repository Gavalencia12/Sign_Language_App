import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/data/speech_texts.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';


class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextToSpeechService ttsService = TextToSpeechService();
  String? currentSection;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSection();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakText());
  }

  Future<void> _loadCurrentSection() async {
      setState(() {
        loading = false;
        currentSection = null;
      });
  }

  Future<void> _speakText() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    if (speakOn) {
      await ttsService.stop();
      final locale = Localizations.localeOf(context);
      final texto = AppLocalizations.of(context)!.learn_info;
      await ttsService.speak(texto, languageCode: locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: const CustomAppBar(title: "LEARNING"),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "LEARNING"),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Lectura por voz"),
            value: Provider.of<SpeechProvider>(context).enabled,
            onChanged: (value) =>
                Provider.of<SpeechProvider>(context, listen: false)
                    .toggleSpeech(value),
          ),
        ],
      ),
    );
  }
}
