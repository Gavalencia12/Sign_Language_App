import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/widgets/levels.dart';
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
  String? currentSection;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSection();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakText());
  }

  Future<void> _loadCurrentSection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Usuario no autenticado, manejar aquí (por ejemplo, navegar a login)
      setState(() {
        loading = false;
        currentSection = null;
      });
      return;
    }

    final userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('progresos');

    final snapshot = await ref.orderByChild('idusuario').equalTo(userId).get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      String seccion = 'seccion_1'; // valor por defecto

      // Extraemos la última sección (puedes adaptar la lógica aquí)
      data.forEach((key, value) {
        final sec = value['idseccion'] ?? '';
        if (sec.compareTo(seccion) > 0) {
          seccion = sec;
        }
      });

      setState(() {
        currentSection = seccion;
        loading = false;
      });
    } else {
      setState(() {
        currentSection = 'seccion_1';
        loading = false;
      });
    }
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

  Widget _buildBodyBySection() {
    switch (currentSection) {
      case 'seccion_1':
        return LevelOneBody();
      case 'seccion_2':
        return LevelTwoBody();
      case 'seccion_3':
        return LevelThreeBody();
      case 'seccion_4':
        return LevelFourBody();
      default:
        return Center(child: Text('Sección no encontrada'));
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
          Expanded(child: _buildBodyBySection()),
        ],
      ),
    );
  }
}
