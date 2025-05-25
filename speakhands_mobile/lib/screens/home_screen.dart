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
import 'package:speakhands_mobile/data/speech_texts.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';

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
        cargarProgresoUsuario(user.uid);
        final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (speakOn) {
          await ttsService.speak(SpeechTexts.homeWelcome(usuario?.nombre ?? "usuario"));
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
    final snapshot = await _dbRef
        .child("progresos")
        .orderByChild("idusuario")
        .equalTo(uid)
        .get();

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A);
    final subTextColor = themeProvider.isDarkMode ? Colors.white70 : Colors.grey.shade700;
    final bellColor = Colors.redAccent;

    return Scaffold(
      appBar: const CustomAppBar(title: "HOME"),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: (usuario?.foto != null && usuario!.foto.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                usuario!.foto,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.person, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hi, Welcome back!", style: TextStyle(color: subTextColor, fontSize: 14)),
                          Text(usuario?.nombre ?? 'User',
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Icon(Icons.notifications_none, size: 28, color: bellColor),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: bellColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "My progress",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              ProgresoWidget(progresos: progresos, iniciarProgreso: iniciarProgreso),
            ],
          ),
        ),
      ),
    );
  }
}
