import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:speakhands_mobile/models/progress_model.dart';
import 'package:speakhands_mobile/widgets/progress.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/widgets/welcome.dart';
import 'package:speakhands_mobile/widgets/path_progress.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextToSpeechService ttsService = TextToSpeechService();

  Usuario? usuario;
  List<Progreso> progresos = [];

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
    ttsService.stop();
  }

  Future<void> cargarDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _dbRef.child("usuarios").child(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          usuario = Usuario.fromMap(snapshot.value as Map<dynamic, dynamic>);
        });
        await cargarProgresoUsuario(user.uid);

        final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (speakOn) {
          final locale = Localizations.localeOf(context);
          final texto = AppLocalizations.of(context)!.home_welcome_with_name(usuario?.nombre ?? "usuario");
          await ttsService.speak(texto, languageCode: locale.languageCode);
        }
      }
    }
  }

  Future<void> cargarProgresoUsuario(String uid) async {
    final snapshot = await _dbRef.child("progresos").orderByChild("idusuario").equalTo(uid).get();

    if (snapshot.exists) {
      List<Progreso> listaProgresos = [];
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        listaProgresos.add(Progreso.fromMap(value, key));
      });

      setState(() {
        progresos = listaProgresos;
      });
    } else {
      setState(() {
        progresos = [];
      });
    }
  }

  Future<void> iniciarProgreso(String uid, String idSeccion) async {
    final snapshot = await _dbRef.child("progresos").orderByChild("idusuario").equalTo(uid).get();

    bool existe = false;

    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value['idseccion'] == idSeccion) {
          existe = true;
        }
      });
    }

    if (existe) {
      return;
    }

    final newProgresoRef = _dbRef.child("progresos").push();

    await newProgresoRef.set({
      'idusuario': uid,
      'idseccion': idSeccion,
      'nivel_aprendizaje': 'beginner',
      'fecha': DateTime.now().toIso8601String(),
      'puntuacion': 0,
    });

    await cargarProgresoUsuario(uid);
  }

  int obtenerSeccionActual() {
    if (progresos.isEmpty) return 0;
    // Supongamos que tomas la última sección
    final lastProgress = progresos.last;
    final seccionStr = lastProgress.idSeccion; // Ejemplo: "seccion_2"
    final parts = seccionStr.split('_');
    if (parts.length == 2) {
      return int.tryParse(parts[1]) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentSectionId = 'seccion_${obtenerSeccionActual()}';

    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A);

    return Scaffold(
      appBar: const CustomAppBar(title: "HOME"),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeWidget(
                userName: usuario?.nombre ?? 'User',
                userPhotoUrl: usuario?.foto,
                isDarkMode: themeProvider.isDarkMode,
              ),
              Text(
                AppLocalizations.of(context)!.my_progress,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              ProgresoWidget(progresos: progresos, iniciarProgreso: iniciarProgreso, idSeccionActual: currentSectionId),
              const SizedBox(height: 20),
              PathProgress(
                totalSections: 6,
                currentSection: obtenerSeccionActual(),
              ),
              ChallengeProgressWidget(
                lessonTitle: AppLocalizations.of(context)!.alphabet_title,
                progressPercent: 0,
                challengeNumber: 26,
                progressSteps: [false, false, false],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
